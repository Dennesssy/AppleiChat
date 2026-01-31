# AppleiChat

On-device AI chat using Apple's FoundationModels with tool use, conversation persistence, and multi-platform support.

## Features

- **On-Device AI** - FoundationModels (Apple Intelligence) for iOS, macOS, visionOS
- **Tool Use** - Model can fetch web content autonomously
- **Conversation Persistence** - Auto-saves to ~/Documents/AppleiChat/ (macOS)
- **Multi-Platform** - iOS, macOS, and visionOS targets
- **Private Cloud Compute** - Falls back to PCC when needed on-device processing
- **CLI Tool** - Command-line interface for batch processing and automation

## Quick Start

### SwiftUI App (iOS/macOS)

```bash
# Build and run in Xcode
open AppleiChat.xcodeproj
# Select AppleiChat scheme → Run (⌘R)
```

### CLI Tool

```bash
# Single query
./Applei-CLI/applei-cli "What is Swift?"

# Interactive mode
./Applei-CLI/applei-cli --interactive

# With custom temperature
./Applei-CLI/applei-cli --temperature 0.8 "Write a poem"
```

## Architecture

```
AppleiChat/
├── SwiftUI App
│   ├── ChatView.swift          # UI with message bubbles
│   ├── ChatViewModel.swift     # LanguageModelSession state
│   ├── Message.swift           # Message model (Codable)
│   └── AppleiChatApp.swift     # Entry point
│
├── Applei-CLI/                 # Command-line tool
│   └── applei-cli.swift        # FetchWebContent tool + interactive mode
│
└── AppleiCode/                 # Xcode Editor Extension
    └── SourceEditorExtension.swift
```

## Requirements

- macOS 15.1+ or iOS 18+
- Apple Silicon (M1+) / A17 Pro or later
- Apple Intelligence enabled in Settings

## Key Implementation Details

### Tool Use
The model has access to `fetch_web_content` tool:
```swift
struct FetchWebContent: Tool {
    let name = "fetch_web_content"
    let description = "Fetch and analyze web content from a URL"

    func call(arguments: Arguments) async throws -> String {
        // Model decides when to call this
    }
}
```

The model autonomously decides when to use this tool based on user requests.

### Conversation State
LanguageModelSession automatically maintains transcript:
```swift
let stream = session.streamResponse(to: prompt, options: options)
// Session keeps full conversation history internally
```

No manual message tracking needed - the session handles context automatically.

### Persistence (SwiftUI only)
Conversations auto-save to JSON:
```swift
saveConversation(name: "current")  // ~/Documents/AppleiChat/current.json
loadLastConversation()              // Auto-loads on app launch
```

## Building

### App
```bash
xcodebuild -scheme AppleiChat -configuration Release
```

### CLI
```bash
cd Applei-CLI
swiftc -parse-as-library -o applei-cli applei-cli.swift \
  -framework FoundationModels -framework Foundation -O
chmod +x applei-cli
```

## Testing

### CLI Testing
```bash
# Test conversation context
printf "What is Swift\nTell me more\nexit\n" | ./applei-cli --interactive

# Test tool use
./applei-cli "fetch https://swift.org and summarize it"
```

### App Testing
1. Launch AppleiChat app
2. Type messages - responds using FoundationModels
3. Previous conversations auto-load on restart
4. Model calls fetch_web_content tool when appropriate

## Submitting to App Store

1. **Archive**: Product → Archive (Xcode)
2. **Distribute**: Select TestFlight or App Store
3. **Sign**: Use your development team
4. **Submit**: Follow App Store review guidelines

The app includes proper entitlements for FoundationModels access.

## Status

✅ Fully functional on-device AI chat
✅ Tool use implementation (FetchWebContent)
✅ Conversation persistence
✅ Multi-platform support
✅ CLI tool with interactive mode
✅ Ready for TestFlight/App Store submission

## License

Private project
