# Applei CLI - Apple Intelligence Command Line Interface

A command-line interface for Apple's FoundationModels framework, enabling on-device AI interactions from the terminal.

## Features

- Single-query mode for one-off questions
- Interactive mode for conversational sessions
- Streaming responses for real-time output
- Model selection (general, contentTagging)
- Temperature control
- Context window management with automatic compression
- On-device processing (privacy-first)

## Requirements

- macOS 15.1 or later
- Apple Intelligence enabled (Settings > Apple Intelligence & Siri)
- Compatible Apple Silicon device

## Installation

### Option 1: Script Mode (Immediate Use)

```bash
chmod +x applei-cli.swift
./applei-cli.swift "Your question here"
```

### Option 2: Compiled Binary (Better Performance)

```bash
swiftc -o applei-cli applei-cli.swift -framework FoundationModels -framework Foundation
chmod +x applei-cli
sudo mv applei-cli /usr/local/bin/  # Optional: install globally
```

## Usage

### Single Query Mode

```bash
# Basic query
./applei-cli.swift "What is Swift?"

# With options
./applei-cli.swift --model general --temperature 0.8 "Explain closures in Swift"

# Custom system instructions
./applei-cli.swift --system "You are a Swift expert" "Best practices for error handling"
```

### Interactive Mode

```bash
./applei-cli.swift --interactive
```

Interactive commands:
- `help` - Show available commands
- `status` - Display session information
- `clear` - Reset conversation history
- `exit` or `quit` - End session

## Command-Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--interactive` | `-i` | Start interactive mode | false |
| `--model` | `-m` | Select model (general, contentTagging) | general |
| `--temperature` | `-t` | Set temperature (0.0-1.0) | 0.7 |
| `--system` | `-s` | Custom system instructions | Default instructions |
| `--help` | `-h` | Show help message | - |

## Examples

### Basic Examples

```bash
# Simple question
./applei-cli.swift "What are the main features of SwiftUI?"

# Code explanation
./applei-cli.swift "Explain what this does: async let result = fetch()"

# Creative writing
./applei-cli.swift --temperature 0.9 "Write a haiku about coding"
```

### Advanced Examples

```bash
# Content tagging model
./applei-cli.swift --model contentTagging "Categorize: Machine learning article about neural networks"

# Interactive session with custom personality
./applei-cli.swift --interactive --system "You are a helpful Swift mentor. Use simple explanations."

# Low temperature for factual responses
./applei-cli.swift --temperature 0.3 "What is the capital of France?"
```

## Architecture

Based on the working `ChatManager.swift` implementation with:

- **Session Management**: Persistent conversation context with automatic compression
- **Streaming**: Real-time response output using async streams
- **Error Handling**: Graceful degradation for context overflow and availability issues
- **Performance**: Session prewarming for reduced latency
- **Privacy**: 100% on-device processing, no data sent to servers

## Configuration

See `.agent-cli` configuration file for detailed settings:

```yaml
model:
  default: general
  use_case: general

generation:
  temperature: 0.7
  streaming: true
  prewarm: true

session:
  persist_context: true
  context_compression: true
  context_retention: 6
```

## Limitations

### Current Limitations (FoundationModels Framework)

1. **No Tool Calling**: The framework does not support function/tool calling as of macOS 15.1
2. **Text Only**: No vision or multimodal inputs
3. **Limited Parameters**: Only temperature control available (no top_p, top_k, etc.)
4. **Context Window**: Managed via message count heuristics (~15-20 messages)
5. **Model Selection**: Limited to use cases (general, contentTagging), not specific models

### Use Cases

**Recommended:**
- Personal Q&A and assistance
- Content tagging and categorization
- Text generation with privacy requirements
- Simple conversational interfaces

**Not Recommended (Yet):**
- Agent systems requiring tool calling
- Complex multi-step workflows
- Systems needing structured JSON outputs
- Guaranteed token control

## Privacy & Security

- **100% On-Device**: All processing happens locally on your Mac
- **No Telemetry**: Apple Intelligence doesn't send data to servers
- **Local Storage**: Conversation history stored in local UserDefaults only
- **No API Keys**: No external API keys or authentication required

## Troubleshooting

### "Device not eligible for Apple Intelligence"
Your Mac doesn't support Apple Intelligence. Requires Apple Silicon (M1 or later).

### "Apple Intelligence not enabled"
Enable Apple Intelligence in System Settings > Apple Intelligence & Siri.

### "Model not ready"
The AI model is still downloading. Wait for download to complete and try again.

### Context Window Exceeded
The CLI automatically creates a new session with condensed context. You can also use the `clear` command in interactive mode.

## Development

### Testing

```bash
# Test availability
./applei-cli.swift "test"

# Test streaming
./applei-cli.swift "Count from 1 to 10"

# Test context management
./applei-cli.swift --interactive
> Tell me a story
> Continue the story
> clear
> status
```

### Debugging

Enable verbose output by modifying the script:
```swift
private func printInfo(_ message: String) {
    print("\u{001B}[36m[INFO]\u{001B}[0m \(message)")
}
```

## Integration with Agent Workflows

**IMPORTANT**: Review the `.agent-cli` configuration file for compatibility notes.

The FoundationModels framework currently focuses on text generation and does not document tool calling capabilities. Before integrating into agent workflows that require function calling:

1. Verify framework capabilities in your macOS version
2. Test structured output support
3. Consider alternative approaches if tool calling is unavailable
4. Monitor Apple's documentation for updates

## References

- Apple TN3193: Using the Apple Intelligence APIs
- FoundationModels Framework Documentation
- ChatManager.swift implementation
- `.agent-cli` configuration file

## License

Based on Apple's FoundationModels framework. Refer to Apple's licensing for the framework itself.

## Author

Created: 2026-01-12
Based on: AppleiChat ChatManager implementation
Framework: Apple FoundationModels
