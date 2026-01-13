//
//  ChatManager.swift
//  AppleiChat
//
//  Created by Dennis Stewart Jr. on 1/12/26.
//

import Foundation
import FoundationModels
import SwiftUI
import Combine

// On-device model use case types
enum ModelUseCase: String, CaseIterable, Identifiable {
    case general = "General"
    case contentTagging = "Content Tagging"

    var id: String { rawValue }

    // NOTE: Review may be needed to determine if model selection is compatible with tool calling features
    var systemModel: SystemLanguageModel {
        switch self {
        case .general:
            return SystemLanguageModel(useCase: .general)
        case .contentTagging:
            return SystemLanguageModel(useCase: .contentTagging)
        }
    }
}

@MainActor
class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var streamingResponse: String?
    @Published var modelAvailability: SystemLanguageModel.Availability
    @Published var tokenWarning: String?
    @Published var selectedModelUseCase: ModelUseCase = .general {
        didSet {
            updateModelSelection()
        }
    }

    private var session: LanguageModelSession?
    private var model: SystemLanguageModel
    private var messageCount = 0
    
    // TN3193: Keep instructions concise (1-3 paragraphs max)
    // Use clear, imperative language
    private let systemInstructions = """
    You are a helpful AI assistant. Provide clear, concise answers.
    Keep responses under 3 paragraphs unless specifically asked for more detail.
    Be accurate and acknowledge uncertainty when appropriate.
    """
    
    init() {
        self.model = ModelUseCase.general.systemModel
        self.modelAvailability = model.availability
        initializeSession()
    }

    // Update model when use case changes
    private func updateModelSelection() {
        self.model = selectedModelUseCase.systemModel
        self.modelAvailability = model.availability

        // Reinitialize session with new model
        initializeSession()

        // Clear messages when switching models to avoid context confusion
        messages.removeAll()
        messageCount = 0
        tokenWarning = nil
    }
    
    private func initializeSession() {
        // Check availability and create session
        modelAvailability = model.availability
        messageCount = 0
        tokenWarning = nil
        
        switch modelAvailability {
        case .available:
            session = LanguageModelSession(instructions: systemInstructions)
            // TN3193: Prewarm to reduce latency
            Task {
                await prewarmSession()
            }
        default:
            session = nil
        }
    }
    
    // TN3193: Use prewarm() to load model into memory and reduce latency
    private func prewarmSession() async {
        guard let session = session else { return }
        await session.prewarm(promptPrefix: nil)
    }
    
    func sendMessage(_ content: String) async {
        // Add user message
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        messageCount += 1

        // TN3193: Warn when approaching context limit (roughly 15-20 messages)
        if messageCount >= 15 {
            tokenWarning = "Conversation getting long. Responses may slow down."
        }

        // Check model availability
        guard modelAvailability == .available, let session = session else {
            let errorMessage = ChatMessage(
                role: .assistant,
                content: getUnavailabilityMessage()
            )
            messages.append(errorMessage)
            return
        }

        // Check if session is busy
        guard !session.isResponding else {
            return
        }

        isGenerating = true
        streamingResponse = ""

        do {
            // Check if message contains URL and fetch context
            var messageContext = content
            if let urls = extractURLs(from: content), !urls.isEmpty {
                for url in urls {
                    if let webContent = try? await fetchWebContent(from: url) {
                        messageContext += "\n\n[Web Context from \(url.host ?? url.absoluteString)]:\n\(webContent)"
                    }
                }
            }

            // TN3193: Use GenerationOptions for better control
            let options = GenerationOptions(temperature: 0.7)

            // Stream the response for real-time updates
            let stream = session.streamResponse(to: messageContext, options: options)

            var fullResponse = ""

            for try await partial in stream {
                // Update streaming response
                streamingResponse = partial.content
                fullResponse = partial.content
            }

            // Add complete response to messages
            streamingResponse = nil

            let assistantMessage = ChatMessage(
                role: .assistant,
                content: fullResponse
            )
            messages.append(assistantMessage)
            messageCount += 1

            // Persist conversation context
            saveConversationContext()

        } catch let error as LanguageModelSession.GenerationError {
            handleGenerationError(error)
        } catch {
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "I encountered an error: \(error.localizedDescription)"
            )
            messages.append(errorMessage)
        }

        isGenerating = false
    }
    
    // TN3193: Handle exceededContextWindowSize elegantly
    private func handleGenerationError(_ error: LanguageModelSession.GenerationError) {
        let message: String
        
        switch error {
        case .exceededContextWindowSize(let context):
            // TN3193: Create new session with condensed context
            message = "Conversation is too long. Starting a fresh session with recent context..."
            
            // Get important entries from the original session
            if let originalSession = session {
                session = newContextualSession(from: originalSession)
                
                // Prewarm the new session
                Task {
                    await prewarmSession()
                }
            }
            
            tokenWarning = nil
            messageCount = messages.count
            
        @unknown default:
            message = "An unexpected error occurred. Please try again."
        }
        
        let errorMessage = ChatMessage(role: .assistant, content: message)
        messages.append(errorMessage)
    }
    
    // TN3193: Create new session with condensed transcript from original
    private func newContextualSession(from originalSession: LanguageModelSession) -> LanguageModelSession {
        let allEntries = originalSession.transcript
        
        // Keep first entry (contains instructions context) and last 3-5 entries
        var condensedEntries: [Transcript.Entry] = []
        
        if let first = allEntries.first {
            condensedEntries.append(first)
        }
        
        // Keep the last few exchanges for continuity
        let recentEntries = allEntries.suffix(6) // Last 3 exchanges (user + assistant)
        condensedEntries.append(contentsOf: recentEntries)
        
        let condensedTranscript = Transcript(entries: condensedEntries)
        return LanguageModelSession(transcript: condensedTranscript)
    }
    
    private func getUnavailabilityMessage() -> String {
        switch modelAvailability {
        case .available:
            return "Model is available."
        case .unavailable(.deviceNotEligible):
            return "This device doesn't support Apple Intelligence. AI features require a compatible device."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Please enable Apple Intelligence in Settings > Apple Intelligence & Siri to use AI features."
        case .unavailable(.modelNotReady):
            return "The AI model is downloading or not ready. Please try again shortly."
        case .unavailable:
            return "The AI model is currently unavailable. Please check your settings and try again."
        }
    }
    
    // Save conversation context using UserDefaults (for demo purposes)
    // In production, consider using SwiftData or other persistent storage
    private func saveConversationContext() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(messages) {
            UserDefaults.standard.set(encoded, forKey: "conversationHistory")
        }
    }
    
    // Load conversation context
    func loadConversationContext() {
        if let savedMessages = UserDefaults.standard.data(forKey: "conversationHistory") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ChatMessage].self, from: savedMessages) {
                // Optionally limit to last N messages to avoid context overflow
                messages = Array(decoded.suffix(20))
            }
        }
    }
    
    // Clear conversation and reset session
    func clearConversation() {
        messages.removeAll()
        messageCount = 0
        tokenWarning = nil
        UserDefaults.standard.removeObject(forKey: "conversationHistory")
        initializeSession()
    }
    
    // TN3193: Provide feedback to Apple (for future implementation)
    func provideFeedback(sentiment: LanguageModelFeedback.Sentiment, for message: ChatMessage) {
        guard let session = session else { return }

        // Log feedback attachment
        let feedbackData = session.logFeedbackAttachment(
            sentiment: sentiment,
            issues: [],
            desiredResponseText: nil
        )

        // In a real app, you would send this to Apple's feedback system
        // For now, we'll just log it
        print("Feedback logged: \(feedbackData.count) bytes")
    }

    // MARK: - Web Fetching Support

    private func extractURLs(from text: String) -> [URL]? {
        let pattern = "https?://[^\\s]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: nsRange)

        return matches.compactMap { match in
            if let range = Range(match.range, in: text) {
                return URL(string: String(text[range]))
            }
            return nil
        }
    }

    private func fetchWebContent(from url: URL) async throws -> String {
        let config = WebFetchConfig(
            url: url,
            waitTime: 1.0,
            timeout: 10,
            mode: .text
        )

        let fetcher = WebFetcher(config: config)
        let result = try await fetcher.fetch()

        // Limit content length to avoid overwhelming the context window
        let maxLength = 2000
        let truncated = result.content.count > maxLength
            ? String(result.content.prefix(maxLength)) + "..."
            : result.content

        return truncated
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    var timestamp: Date
    var isStreaming: Bool = false
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date(), isStreaming: Bool = false) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
    }
    
    enum CodingKeys: String, CodingKey {
        case id, role, content, timestamp
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}
