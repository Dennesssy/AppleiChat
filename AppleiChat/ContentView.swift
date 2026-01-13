//
//  ContentView.swift
//  AppleiChat
//
//  Created by Dennis Stewart Jr. on 1/12/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingChat = false
    @StateObject private var chatManager = ChatManager()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content area - Chat History
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "brain.fill")
                            .font(.title2)
                            .foregroundStyle(.blue.gradient)
                        
                        Text("AI Assistant")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Text("Private, on-device conversations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
                
                Divider()
                
                // Chat history
                if chatManager.messages.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "message.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient.opacity(0.3))
                        
                        Text("No conversations yet")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Text("Start a new conversation by tapping the button below")
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    // Recent conversations
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            Text("Recent Conversations")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            ForEach(chatManager.messages) { message in
                                ChatHistoryRow(message: message)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Floating chat window with glass effect
            if isShowingChat {
                ChatWindowView(isPresented: $isShowingChat, chatManager: chatManager)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
            
            // Floating action button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.68)) {
                    isShowingChat.toggle()
                }
            } label: {
                Image(systemName: isShowingChat ? "xmark" : "message.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue.gradient)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
            }
            .padding(24)
        }
        .onAppear {
            chatManager.loadConversationContext()
        }
    }
}

// Chat history row view
struct ChatHistoryRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: message.role == .user ? "person.circle.fill" : "sparkles")
                .font(.title3)
                .foregroundStyle(message.role == .user ? .blue.gradient : .purple)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.role == .user ? "You" : "AI Assistant")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(message.content)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Text(message.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
