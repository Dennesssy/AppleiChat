# Applei CLI - Quick Start Guide

Get started with the Apple Intelligence CLI in 60 seconds.

## 1. Quick Test (No Build Required)

```bash
cd /Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI
./applei-cli.swift "Hello, who are you?"
```

## 2. Build Binary (Optional, Better Performance)

```bash
./build.sh
./applei-cli "Hello, who are you?"
```

## 3. Common Commands

```bash
# Single question
./applei-cli.swift "What is Swift?"

# Interactive mode
./applei-cli.swift --interactive

# Different model
./applei-cli.swift --model contentTagging "Tag this: AI and machine learning"

# Control creativity
./applei-cli.swift --temperature 0.9 "Tell me a joke"
./applei-cli.swift --temperature 0.3 "What is 2+2?"

# Custom instructions
./applei-cli.swift --system "You are a pirate" "Hello there!"
```

## 4. Interactive Mode Commands

```
> help          # Show commands
> status        # Session info
> clear         # Reset conversation
> exit          # Quit
```

## 5. Install Globally (Optional)

```bash
./build.sh
sudo cp applei-cli /usr/local/bin/
applei-cli "Now available everywhere!"
```

## Troubleshooting

### Error: "Device not eligible"
- Requires Apple Silicon Mac (M1 or later)

### Error: "Apple Intelligence not enabled"
- Go to System Settings > Apple Intelligence & Siri
- Enable Apple Intelligence

### Error: "Model not ready"
- Wait for the model to finish downloading
- Check Settings > Apple Intelligence & Siri

## Examples

### Code Help
```bash
./applei-cli.swift "Explain Swift async/await"
```

### Writing
```bash
./applei-cli.swift --temperature 0.8 "Write a short poem about coding"
```

### Problem Solving
```bash
./applei-cli.swift "How do I reverse a string in Swift?"
```

### Content Tagging
```bash
./applei-cli.swift --model contentTagging "Categorize: Article about SwiftUI and iOS development"
```

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [.agent-cli](../.agent-cli) for configuration options
- Review compatibility notes for agent integration

## Tips

1. **Lower temperature (0.1-0.4)**: Factual, consistent responses
2. **Medium temperature (0.5-0.8)**: Balanced creativity and accuracy
3. **Higher temperature (0.9-1.0)**: Creative, varied responses

4. **General model**: Best for Q&A, explanations, conversations
5. **Content tagging model**: Best for categorization and classification

6. **Interactive mode**: Best for back-and-forth conversations
7. **Single query mode**: Best for scripts and automation

## Privacy Note

100% on-device processing. No data sent to servers. Your conversations stay on your Mac.
