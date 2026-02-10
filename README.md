# Apple Intelligence CLI

On-device AI chat using Apple's FoundationModels with advanced tool use, task persistence, and multi-platform support.

## Features

- **On-Device AI** - FoundationModels (Apple Intelligence) for iOS, macOS, visionOS
- **8 Powerful Tools** - Web fetching, file operations, system monitoring, project analysis
- **Task Persistence** - Resume long-running tasks across context resets
- **Conversation Persistence** - Auto-saves to ~/Documents/AppleiChat/ (macOS)
- **Multi-Platform** - iOS, macOS, and visionOS targets
- **Private Cloud Compute** - Falls back to PCC when needed
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

## Available Tools

The agent has access to 8 tools that it can use autonomously:

### 1. fetch_web_content
Fetch and analyze web pages using SwiftFejs.

```bash
./applei-cli "Fetch https://swift.org and summarize it"
```

### 2. system_monitor
Display RAM usage, CPU stats, and running processes.

```bash
./applei-cli "Show me system RAM usage"
```

### 3. list_processes
List all currently running system processes.

```bash
./applei-cli "What processes are running?"
```

### 4. bash_execute
Execute bash commands directly on the system.

```bash
./applei-cli "List files in the current directory"
```

### 5. read_file
Read contents of text files from the filesystem.

```bash
./applei-cli "Read the file README.md"
```

### 6. analyze_project
Parallel read and analyze all Swift files in a directory (max 10 files).

```bash
./applei-cli "Analyze the project at /path/to/project"
```

### 7. edit_file
Create or overwrite files with new content.

```bash
./applei-cli "Create a file hello.txt with content 'Hello World'"
```

### 8. manage_task_state
Save and load task progress for long-running operations.

```bash
# Agent automatically uses this for multi-step tasks
./applei-cli "Complete these 5 steps: [task description]"

# Manual usage
./applei-cli "Save task state: goal is 'build app', completed 'step1,step2', remaining 'step3'"
./applei-cli "Load the saved task state"
```

## Task Persistence

For long-running tasks that exceed context window limits:

```bash
./applei-cli "I have a 10-step task: [describe steps]. Save progress after each step."
```

The agent will:
1. Automatically save progress after major steps
2. Load previous state if context resets
3. Resume from where it left off
4. Track context reset count

Task state is saved to: `~/Documents/AppleiChat/task_state.json`

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
│   ├── applei-cli.swift        # Main CLI with 8 tools
│   └── swiftfejs               # Web content fetcher
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
The model autonomously decides when to use tools based on user requests:

```swift
struct FetchWebContent: Tool {
    let name = "fetch_web_content"
    let description = "Fetch and analyze web content from a URL"

    func call(arguments: Arguments) async throws -> String {
        // Model decides when to call this
    }
}
```

### Task State Management
Long-running tasks persist across context resets:

```swift
struct TaskState: Codable {
    let goal: String
    let completedSteps: [String]
    let remainingSteps: [String]
    let lastUpdated: String
    let contextResets: Int
}
```

### Context Window Management
When context fills up (~8K-16K tokens):
- Keeps first message (initial instructions)
- Keeps last 6 messages
- Drops middle conversation
- Increments context reset counter in task state

### Conversation State
LanguageModelSession automatically maintains transcript:
```swift
let stream = session.streamResponse(to: prompt, options: options)
// Session keeps full conversation history internally
```

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
./applei-cli "Fetch https://swift.org and summarize it"

# Test file operations
./applei-cli "Create a file test.txt with 'Hello', then read it back"

# Test project analysis
./applei-cli "Analyze the Swift files in ./AppleiChat"

# Test task persistence
./applei-cli "Save task: goal 'test', completed 'step1', remaining 'step2'"
./applei-cli "Load task state"
```

### App Testing
1. Launch AppleiChat app
2. Type messages - responds using FoundationModels
3. Previous conversations auto-load on restart
4. Model calls tools when appropriate

## Advanced Usage

### Batch Processing
```bash
# Create a script with multiple queries
cat > queries.txt << EOF
What is SwiftUI?
Explain Combine framework
Define async/await
EOF

while read query; do
  ./applei-cli "$query"
done < queries.txt
```

### Apple Shortcuts Integration
Create a shortcut that runs:
```bash
/path/to/applei-cli "Your query here"
```

### Custom System Instructions
```bash
./applei-cli --system "You are a Swift expert" "Explain protocols"
```

## Performance

- Simple queries: 3-6 seconds
- Tool invocations: 6-12 seconds
- Context window: ~8K-16K tokens
- Concurrent instances: 1-2 system-wide (Apple limitation)
- Rate limiting: System-level enforcement

## Future Improvements

- Token estimation for better context management
- Parallel tool execution using Combine
- AI-powered summarization before context resets
- Task state versioning and rollback
- Enhanced error recovery with retry logic
- Performance telemetry and metrics
- Multi-session support with UUIDs

## Submitting to App Store

1. **Archive**: Product → Archive (Xcode)
2. **Distribute**: Select TestFlight or App Store
3. **Sign**: Use your development team
4. **Submit**: Follow App Store review guidelines

The app includes proper entitlements for FoundationModels access.

## Status

✅ Fully functional on-device AI chat
✅ 8 tools with autonomous usage
✅ Task persistence across context resets
✅ Conversation persistence
✅ Multi-platform support
✅ CLI tool with interactive mode
✅ Ready for TestFlight/App Store submission

## License

Private project
