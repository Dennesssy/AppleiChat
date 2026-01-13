import WebKit
import Foundation

// MARK: - Types

enum WebFetchMode: String {
    case html
    case text
    case links
    case json
    case scripts
}

struct WebFetchConfig {
    let url: URL
    let waitTime: TimeInterval
    let timeout: TimeInterval
    let mode: WebFetchMode
}

struct WebPageResult: Codable {
    let title: String
    let url: String
    let content: String
    let links: [LinkInfo]?
    let scripts: [ScriptInfo]?
    let metadata: [String: String]?
}

struct LinkInfo: Codable {
    let text: String
    let href: String
}

struct ScriptInfo: Codable {
    let src: String
    let type: String
}

// MARK: - JavaScript Scripts

struct WebScripts {
    static let extractText = """
        (function() {
            const clone = document.body.cloneNode(true);
            const hidden = clone.querySelectorAll('[hidden], [style*="display: none"], script, style, noscript');
            hidden.forEach(el => el.remove());
            return clone.innerText;
        })()
    """

    static let extractLinks = """
        Array.from(document.querySelectorAll('a')).map(a => ({
            text: a.innerText.trim().replace(/\\\\s+/g, ' '),
            href: a.href
        }))
    """

    static let extractScripts = """
        Array.from(document.querySelectorAll('script')).map(s => ({
            src: s.src || '',
            type: s.type || 'text/javascript'
        }))
    """

    static let extractMetadata = """
        (function() {
            const meta = {};
            Array.from(document.querySelectorAll('meta')).forEach(m => {
                const key = m.getAttribute('name') || m.getAttribute('property');
                const val = m.getAttribute('content');
                if (key && val) meta[key] = val;
            });
            return meta;
        })()
    """

    static let extractAllJSON = """
        (function() {
            const clone = document.body.cloneNode(true);
            clone.querySelectorAll('script, style, noscript, [hidden]').forEach(e => e.remove());
            const text = clone.innerText;

            const links = Array.from(document.querySelectorAll('a')).map(a => ({
                text: a.innerText.trim().replace(/\\\\s+/g, ' '),
                href: a.href
            }));

            const scripts = Array.from(document.querySelectorAll('script')).map(s => ({
                src: s.src || '',
                type: s.type || ''
            }));

            const metadata = {};
            Array.from(document.querySelectorAll('meta')).forEach(m => {
                const key = m.getAttribute('name') || m.getAttribute('property');
                const val = m.getAttribute('content');
                if (key && val) metadata[key] = val;
            });

            return {
                title: document.title,
                text: text,
                links: links,
                scripts: scripts,
                metadata: metadata
            };
        })()
    """
}

// MARK: - WebFetcher

@MainActor
class WebFetcher: NSObject, WKNavigationDelegate {
    private let config: WebFetchConfig
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<WebPageResult, Error>?

    init(config: WebFetchConfig) {
        self.config = config
        super.init()
    }

    func fetch() async throws -> WebPageResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let configuration = WKWebViewConfiguration()
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = prefs

            let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 1280, height: 1024), configuration: configuration)
            self.webView = wv
            wv.navigationDelegate = self
            wv.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"

            wv.load(URLRequest(url: config.url))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task {
            if config.waitTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(config.waitTime * 1_000_000_000))
            }

            do {
                let result = try await extractContent(from: webView)
                continuation?.resume(returning: result)
            } catch {
                continuation?.resume(throwing: error)
            }
            continuation = nil
            self.webView = nil
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    private func extractContent(from webView: WKWebView) async throws -> WebPageResult {
        let title = try await webView.evaluateJavaScript("document.title") as? String ?? ""
        let url = webView.url?.absoluteString ?? config.url.absoluteString

        switch config.mode {
        case .html:
            let html = try await webView.evaluateJavaScript("document.documentElement.outerHTML") as? String ?? ""
            return WebPageResult(title: title, url: url, content: html, links: nil, scripts: nil, metadata: nil)

        case .text:
            let text = try await webView.evaluateJavaScript(WebScripts.extractText) as? String ?? ""
            return WebPageResult(title: title, url: url, content: text, links: nil, scripts: nil, metadata: nil)

        case .links:
            let linksData = try await webView.evaluateJavaScript(WebScripts.extractLinks)
            let linksJSON = try JSONSerialization.data(withJSONObject: linksData ?? [], options: [])
            let links = try JSONDecoder().decode([LinkInfo].self, from: linksJSON)
            return WebPageResult(title: title, url: url, content: "", links: links, scripts: nil, metadata: nil)

        case .scripts:
            let scriptsData = try await webView.evaluateJavaScript(WebScripts.extractScripts)
            let scriptsJSON = try JSONSerialization.data(withJSONObject: scriptsData ?? [], options: [])
            let scripts = try JSONDecoder().decode([ScriptInfo].self, from: scriptsJSON)
            return WebPageResult(title: title, url: url, content: "", links: nil, scripts: scripts, metadata: nil)

        case .json:
            let allData = try await webView.evaluateJavaScript(WebScripts.extractAllJSON)
            guard let dict = allData as? [String: Any] else {
                throw URLError(.cannotDecodeRawData)
            }

            let text = dict["text"] as? String ?? ""

            var links: [LinkInfo] = []
            if let linkArr = dict["links"] as? [[String: Any]] {
                for l in linkArr {
                    if let t = l["text"] as? String, let h = l["href"] as? String {
                        links.append(LinkInfo(text: t, href: h))
                    }
                }
            }

            var scripts: [ScriptInfo] = []
            if let scriptArr = dict["scripts"] as? [[String: Any]] {
                for s in scriptArr {
                    if let src = s["src"] as? String, let type = s["type"] as? String {
                        scripts.append(ScriptInfo(src: src, type: type))
                    }
                }
            }

            let metadata = dict["metadata"] as? [String: String]

            return WebPageResult(title: title, url: url, content: text, links: links, scripts: scripts, metadata: metadata)
        }
    }
}
