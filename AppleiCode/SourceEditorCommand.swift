import Foundation
import XcodeKit
import UniformTypeIdentifiers

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    // MARK: - Configuration
    private let appGroupIdentifier = "group.com.yourcompany.appleicode"

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let commandIdentifier = invocation.commandIdentifier

        // Remove unnecessary try/catch since these are simple method calls
        if commandIdentifier.contains("SendToChat") {
            sendContextToAI(invocation: invocation, completionHandler: completionHandler)
        } else if commandIdentifier.contains("InsertFromChat") {
            insertCodeFromAI(invocation: invocation, completionHandler: completionHandler)
        } else if commandIdentifier.contains("ReplaceWithAI") {
            replaceSelectionWithAI(invocation: invocation, completionHandler: completionHandler)
        } else if commandIdentifier.contains("ReplaceFileWithAI") {
            replaceFileWithAI(invocation: invocation, completionHandler: completionHandler)
        } else {
            completionHandler(nil)
        }
    }

    // MARK: - Context Capture (Sensor)
    private func sendContextToAI(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer

        // Get the file URL from the buffer's file path if available
        guard let filePath = buffer.lines.firstObject as? String else {
            completionHandler(NSError(
                domain: "SourceEditorCommand",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "File path not available"]
            ))
            return
        }

        // Create URL from file path
        let fileURL = URL(fileURLWithPath: filePath)

        do {
            // Capture full context
            let fullFile = buffer.completeBuffer
            let language = getFileExtension(from: buffer.contentUTI)
            let selectedText = try getSelectedText(from: buffer)
            let selection = getSelectionRange(from: buffer)
            let cursor = getCursorPosition(from: buffer)
            let surroundingLines = getSurroundingLines(from: buffer)
            let projectFiles = getProjectFiles(from: buffer)

            // Determine action
            let action: XcodeAction = selectedText != nil ? .sendToChat : .sendToChat

            // Create enhanced context
            let context = XcodeContext(
                fileURL: fileURL.path,
                language: language,
                fullFile: fullFile,
                selectedText: selectedText,
                selection: selection,
                cursor: cursor,
                surroundingLines: surroundingLines,
                projectFiles: projectFiles,
                action: action,
                timestamp: Date()
            )

            // Save to shared container
            try saveContextToAppGroup(context)

            // Notify main app
            notifyMainApp()

            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    // MARK: - Code Application (Actuator)
    private func insertCodeFromAI(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        do {
            let codeToInsert = try readCodeFromAppGroup()
            let buffer = invocation.buffer
            if let selection = buffer.selections.firstObject as? XCSourceTextRange {
                insertCode(codeToInsert, at: selection, in: buffer)
            }

            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    private func replaceSelectionWithAI(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        do {
            let codeToInsert = try readCodeFromAppGroup()
            let buffer = invocation.buffer
            guard let selection = buffer.selections.firstObject as? XCSourceTextRange else {
                completionHandler(NSError(domain: "SourceEditorCommand", code: 4, userInfo: [NSLocalizedDescriptionKey: "No text selected"]))
                return
            }

            replaceCode(codeToInsert, at: selection, in: buffer, replaceOnlySelection: true)

            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    private func replaceFileWithAI(invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        do {
            let codeToInsert = try readCodeFromAppGroup()
            let buffer = invocation.buffer
            guard let selection = buffer.selections.firstObject as? XCSourceTextRange else {
                completionHandler(NSError(domain: "SourceEditorCommand", code: 6, userInfo: [NSLocalizedDescriptionKey: "No file buffer available"]))
                return
            }

            replaceCode(codeToInsert, at: selection, in: buffer, replaceOnlySelection: false)

            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    // MARK: - Context Capture Helpers
    private func getSelectedText(from buffer: XCSourceTextBuffer) throws -> String? {
        guard let selection = buffer.selections.firstObject as? XCSourceTextRange else { return nil }
        var result = ""

        for lineIndex in selection.start.line...selection.end.line {
            guard let line = buffer.lines[lineIndex] as? String else { continue }

            if lineIndex == selection.start.line && lineIndex == selection.end.line {
                let start = line.index(line.startIndex, offsetBy: selection.start.column)
                let end = line.index(line.startIndex, offsetBy: selection.end.column)
                result += String(line[start..<end])
            } else if lineIndex == selection.start.line {
                let start = line.index(line.startIndex, offsetBy: selection.start.column)
                result += String(line[start...]) + "\n"
            } else if lineIndex == selection.end.line {
                let end = line.index(line.startIndex, offsetBy: selection.end.column)
                result += String(line[..<end])
            } else {
                result += line + "\n"
            }
        }

        return result
    }

    private func getFileExtension(from uti: String) -> String {
        if let type = UTType(uti) {
            if let ext = type.preferredFilenameExtension {
                return ext
            }
        }

        let mapping: [String: String] = [
            "public.swift-source": "swift",
            "public.objective-c-source": "m",
            "public.c-source": "c",
            "public.c-plus-plus-source": "cpp",
            "public.header": "h",
            "public.objc-header": "h",
            "public.json": "json",
            "public.plain-text": "txt"
        ]

        return mapping[uti] ?? "txt"
    }

    private func getSelectionRange(from buffer: XCSourceTextBuffer) -> SelectionRange {
        guard let selection = buffer.selections.firstObject as? XCSourceTextRange else {
            return SelectionRange(startLine: 0, startColumn: 0, endLine: 0, endColumn: 0)
        }

        return SelectionRange(
            startLine: selection.start.line,
            startColumn: selection.start.column,
            endLine: selection.end.line,
            endColumn: selection.end.column
        )
    }

    private func getCursorPosition(from buffer: XCSourceTextBuffer) -> CursorPosition {
        guard let selection = buffer.selections.firstObject as? XCSourceTextRange else {
            return CursorPosition(line: 0, column: 0)
        }

        return CursorPosition(line: selection.start.line, column: selection.start.column)
    }

    private func getSurroundingLines(from buffer: XCSourceTextBuffer) -> [String] {
        guard let selection = buffer.selections.firstObject as? XCSourceTextRange else {
            return []
        }

        let startLine = max(0, selection.start.line - 5)
        let endLine = min(buffer.lines.count - 1, selection.end.line + 5)
        var result: [String] = []

        for lineNumber in startLine...endLine {
            if let line = buffer.lines[lineNumber] as? String {
                result.append(line)
            }
        }

        return result
    }

    private func getProjectFiles(from buffer: XCSourceTextBuffer) -> [ProjectFileRef] {
        // This is optional - for more advanced context
        return []
    }

    // MARK: - Code Manipulation Helpers
    private func insertCode(_ code: String, at selection: XCSourceTextRange, in buffer: XCSourceTextBuffer) {
        // Insert code at the cursor position
        let codeLines = code.components(separatedBy: .newlines)
        for (index, line) in codeLines.enumerated() {
            if index == 0 {
                // For the first line, append to the current line
                if let currentLine = buffer.lines[selection.start.line] as? String {
                    var updatedLine = currentLine
                    let insertIndex = updatedLine.index(updatedLine.startIndex, offsetBy: selection.start.column)
                    updatedLine.insert(contentsOf: line, at: insertIndex)
                    buffer.lines[selection.start.line] = updatedLine
                }
            } else {
                // For subsequent lines, add as new lines
                buffer.lines.insert(line + "\n", at: selection.start.line + index)
            }
        }
    }

    private func replaceCode(_ code: String, at selection: XCSourceTextRange, in buffer: XCSourceTextBuffer, replaceOnlySelection: Bool) {
        if replaceOnlySelection {
            // Delete current selection
            for lineIndex in (selection.start.line...selection.end.line).reversed() {
                if lineIndex == selection.start.line && lineIndex == selection.end.line {
                    guard var line = buffer.lines[lineIndex] as? String else { continue }
                    let startIndex = line.index(line.startIndex, offsetBy: selection.start.column)
                    let endIndex = line.index(line.startIndex, offsetBy: selection.end.column)
                    line.removeSubrange(startIndex..<endIndex)
                    buffer.lines[lineIndex] = line
                } else if lineIndex == selection.start.line {
                    guard var line = buffer.lines[lineIndex] as? String else { continue }
                    let startIndex = line.index(line.startIndex, offsetBy: selection.start.column)
                    line.removeSubrange(startIndex...)
                    buffer.lines[lineIndex] = line
                } else if lineIndex == selection.end.line {
                    guard var line = buffer.lines[lineIndex] as? String else { continue }
                    let endIndex = line.index(line.startIndex, offsetBy: selection.end.column)
                    line.removeSubrange(..<endIndex)
                    buffer.lines[lineIndex] = line
                } else {
                    buffer.lines.removeObject(at: lineIndex)
                }
            }
        } else {
            // Delete all content
            buffer.lines.removeAllObjects()
        }

        // Insert new code
        let codeLines = code.components(separatedBy: .newlines)
        for line in codeLines {
            buffer.lines.add(line + "\n")
        }
    }

    // MARK: - App Group Communication
    private func saveContextToAppGroup(_ context: XcodeContext) throws {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw NSError(domain: "SourceEditorCommand", code: 1001,
                          userInfo: [NSLocalizedDescriptionKey: "App Group container not found"])
        }

        let fileURL = containerURL.appendingPathComponent("xcode-context-enhanced.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(context)
        try data.write(to: fileURL)
    }

    private func readCodeFromAppGroup() throws -> String {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw NSError(domain: "SourceEditorCommand", code: 1002,
                          userInfo: [NSLocalizedDescriptionKey: "App Group container not found"])
        }

        let fileURL = containerURL.appendingPathComponent("ai-generated-code.txt")
        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    private func notifyMainApp() {
        if let defaults = UserDefaults(suiteName: appGroupIdentifier) {
            defaults.set(Date().timeIntervalSince1970, forKey: "xcodeContextUpdated")
            defaults.synchronize()
        }
    }
}

struct SelectionRange: Codable {
    let startLine: Int
    let startColumn: Int
    let endLine: Int
    let endColumn: Int
}

struct CursorPosition: Codable {
    let line: Int
    let column: Int
}

struct ProjectFileRef: Codable {
    let path: String
    let uti: String
}

struct XcodeContext: Codable {
    let fileURL: String
    let language: String
    let fullFile: String
    let selectedText: String?
    let selection: SelectionRange
    let cursor: CursorPosition
    let surroundingLines: [String]
    let projectFiles: [ProjectFileRef]
    let action: XcodeAction
    let timestamp: Date
}

enum XcodeAction: String, Codable {
    case sendToChat
    case insertFromChat
    case replaceSelection
    case replaceFile
}
