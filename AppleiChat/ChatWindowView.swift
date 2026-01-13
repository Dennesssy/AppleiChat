//
//  ChatWindowView.swift
//  AppleiChat
//
//  Created by Dennis Stewart Jr. on 1/12/26.
//

import SwiftUI
import FoundationModels

struct ChatWindowView: View {
    @Binding var isPresented: Bool
    @ObservedObject var chatManager: ChatManager
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @Namespace private var glassNamespace
    
    // Dynamic height based on content
    private var windowHeight: CGFloat {
        if chatManager.messages.isEmpty {
            return 200 // Compact for new conversation
        } else {
            return min(600, CGFloat(chatManager.messages.count) * 100 + 200)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact Header
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.body)
                            .foregroundStyle(.blue.gradient)

                        Text("AI Chat")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    // Model selector
                    Picker("Model", selection: $chatManager.selectedModelUseCase) {
                        ForEach(ModelUseCase.allCases) { useCase in
                            Text(useCase.rawValue)
                                .font(.caption)
                                .tag(useCase)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)

                    // Model status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())

                    // Smaller close button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 24, height: 24)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Messages area
            if chatManager.messages.isEmpty {
                // Empty state for new conversation
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue.gradient.opacity(0.5))
                    
                    Text("Start a conversation")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 120)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatManager.messages) { message in
                                MessageBubbleView(message: message)
                                    .environmentObject(chatManager)
                                    .id(message.id)
                            }
                            
                            // Streaming response indicator
                            if chatManager.isGenerating, let partial = chatManager.streamingResponse {
                                MessageBubbleView(
                                    message: ChatMessage(
                                        role: .assistant,
                                        content: partial,
                                        isStreaming: true
                                    )
                                )
                                .environmentObject(chatManager)
                                .id("streaming")
                            }
                        }
                        .padding(16)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: chatManager.messages.count) { _, _ in
                        withAnimation(.smooth) {
                            if let lastMessage = chatManager.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: chatManager.streamingResponse) { _, _ in
                        withAnimation(.smooth) {
                            proxy.scrollTo("streaming", anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Compact input area
            HStack(spacing: 10) {
                TextField("Message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .onSubmit {
                        sendMessage()
                    }
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue.gradient)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isGenerating)
                .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(.regularMaterial)
        }
        .frame(width: 380, height: windowHeight)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .padding(20)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: windowHeight)
        .onAppear {
            isInputFocused = true
        }
    }
    
    private var statusColor: Color {
        switch chatManager.modelAvailability {
        case .available:
            return .green
        case .unavailable(.appleIntelligenceNotEnabled):
            return .orange
        default:
            return .red
        }
    }
    
    private var statusText: String {
        switch chatManager.modelAvailability {
        case .available:
            return "On-Device"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Enable AI"
        default:
            return "Offline"
        }
    }
    
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = inputText
        inputText = ""
        
        // Haptic feedback
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
        
        Task {
            await chatManager.sendMessage(userMessage)
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    @EnvironmentObject var chatManager: ChatManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .textSelection(.enabled)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .background {
                        if message.role == .user {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.blue.gradient)
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .overlay {
                        if message.role == .assistant {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                        }
                    }
                
                // Timestamp
                HStack(spacing: 4) {
                    if message.isStreaming {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.05).ignoresSafeArea()
        ChatWindowView(isPresented: .constant(true), chatManager: ChatManager())
    }
}
