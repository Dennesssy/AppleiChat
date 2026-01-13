# Applei CLI - Complete Index

Central reference for all Applei CLI files and resources.

## Quick Navigation

### For Users

| Need | File | Description |
|------|------|-------------|
| **Get started fast** | [QUICKSTART.md](QUICKSTART.md) | 60-second setup and usage |
| **Full documentation** | [README.md](README.md) | Complete reference guide |
| **See examples** | [examples/](examples/) | Working code samples |
| **Project overview** | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Complete project details |

### For Developers

| Need | File | Description |
|------|------|-------------|
| **Source code** | [applei-cli.swift](applei-cli.swift) | Main CLI implementation |
| **Build tool** | [build.sh](build.sh) | Compilation script |
| **Run tests** | [test.sh](test.sh) | Automated testing |
| **Configuration** | [../.agent-cli](../.agent-cli) | Agent config file |
| **Structure** | [STRUCTURE.md](STRUCTURE.md) | Architecture overview |

## File Catalog

### Core Implementation (2 files)

1. **applei-cli.swift** (371 lines, 11KB)
   - Main CLI tool implementation
   - Supports single-query and interactive modes
   - Model selection and temperature control
   - Streaming responses
   - Context management
   - Location: `/Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI/applei-cli.swift`

2. **.agent-cli** (160 lines, 6.3KB)
   - Configuration for agent workflows
   - Model settings and parameters
   - **Important compatibility notes**
   - Review needed for tool calling features
   - Location: `/Users/denn/Desktop/Xcode/AppleiChat/.agent-cli`

### Documentation (5 files)

1. **README.md** (6.4KB)
   - Complete documentation
   - Installation instructions
   - Usage guide
   - Troubleshooting
   - API reference

2. **QUICKSTART.md** (2.6KB)
   - 60-second setup
   - Common commands
   - Quick troubleshooting
   - Essential examples

3. **PROJECT_SUMMARY.md** (9.7KB)
   - Complete project overview
   - All created files
   - Architecture details
   - Success criteria
   - Version information

4. **STRUCTURE.md** (16KB)
   - Visual project structure
   - Component breakdown
   - Data flow diagrams
   - Integration points
   - Quick reference

5. **INDEX.md** (this file)
   - Central navigation
   - File catalog
   - Quick links
   - Reading paths

### Build & Test Scripts (2 files)

1. **build.sh** (1.1KB)
   - Compiles Swift to binary
   - Checks dependencies
   - Creates optimized executable
   - Installation guidance

2. **test.sh** (973B)
   - Automated test suite
   - Verifies functionality
   - Tests all features
   - Manual test guide

### Examples (5 files)

1. **batch-queries.sh** (529B)
   - Process multiple questions
   - Automation example
   - Batch processing pattern

2. **content-tagger.sh** (756B)
   - Content categorization
   - Uses contentTagging model
   - Classification examples

3. **temperature-test.sh** (650B)
   - Compare temperatures
   - Creativity vs consistency
   - Parameter tuning guide

4. **code-helper.sh** (806B)
   - Coding assistance
   - Custom instructions
   - Development support

5. **examples/README.md** (2.5KB)
   - Examples documentation
   - Integration ideas
   - Best practices
   - Usage patterns

## Reading Paths

### Path 1: Quick Start (5 minutes)

```
1. QUICKSTART.md
   ↓
2. Run: ./applei-cli.swift "Hello"
   ↓
3. Try examples: cd examples && ./batch-queries.sh
```

### Path 2: Full Setup (15 minutes)

```
1. QUICKSTART.md
   ↓
2. README.md (Installation section)
   ↓
3. ./build.sh
   ↓
4. README.md (Usage section)
   ↓
5. ./test.sh
```

### Path 3: Development Understanding (30 minutes)

```
1. PROJECT_SUMMARY.md
   ↓
2. STRUCTURE.md
   ↓
3. applei-cli.swift (read source)
   ↓
4. .agent-cli (review configuration)
   ↓
5. examples/ (study patterns)
```

### Path 4: Agent Integration (45 minutes)

```
1. .agent-cli (compatibility notes)
   ↓
2. PROJECT_SUMMARY.md (limitations section)
   ↓
3. README.md (integration section)
   ↓
4. applei-cli.swift (session management)
   ↓
5. Test tool calling capabilities
```

## Key Locations

### Absolute Paths

```
Main Directory:
/Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI/

Configuration:
/Users/denn/Desktop/Xcode/AppleiChat/.agent-cli

Main CLI:
/Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI/applei-cli.swift

Examples:
/Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI/examples/

Documentation:
/Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI/*.md
```

## Common Tasks

### Run the CLI

```bash
# Script mode
./applei-cli.swift "Your question"

# Interactive mode
./applei-cli.swift --interactive

# With options
./applei-cli.swift --model general --temperature 0.8 "Question"
```

### Build Binary

```bash
./build.sh
./applei-cli "Your question"
```

### Run Tests

```bash
./test.sh
```

### Try Examples

```bash
cd examples
./batch-queries.sh
./temperature-test.sh
./code-helper.sh
./content-tagger.sh
```

### Install Globally

```bash
./build.sh
sudo cp applei-cli /usr/local/bin/
applei-cli "Now available everywhere"
```

## Important Notes

### Compatibility Review Required

From `.agent-cli`:

> **IMPORTANT COMPATIBILITY REVIEW NEEDED**
>
> Tool Calling Features:
> - Apple's FoundationModels framework (TN3193) does not explicitly document
>   tool calling or function calling capabilities as of macOS 15.1
> - Review needed before using in agent workflows requiring tool calling
> - See `.agent-cli` for detailed compatibility notes

### System Requirements

- macOS 15.1 or later
- Apple Intelligence enabled
- Compatible Apple Silicon device (M1 or later)

### Privacy

- 100% on-device processing
- No data sent to servers
- Local storage only
- No API keys required

## Feature Matrix

| Feature | Supported | Notes |
|---------|-----------|-------|
| Text generation | ✅ Yes | Streaming and non-streaming |
| Interactive mode | ✅ Yes | Multi-turn conversations |
| Model selection | ✅ Yes | general, contentTagging |
| Temperature control | ✅ Yes | 0.0-1.0 |
| System instructions | ✅ Yes | Custom instructions |
| Context management | ✅ Yes | Auto-compression |
| Streaming output | ✅ Yes | Real-time responses |
| Colored output | ✅ Yes | ANSI colors |
| Tool calling | ❓ Unknown | Requires verification |
| Structured outputs | ❓ Unknown | Not documented |
| Vision/multimodal | ❌ No | Text only |
| Custom parameters | ⚠️ Limited | Temperature only |

## Support Resources

### Troubleshooting

1. Check [QUICKSTART.md](QUICKSTART.md) - Quick fixes
2. Check [README.md](README.md) - Detailed troubleshooting
3. Review [.agent-cli](../.agent-cli) - Configuration issues
4. Check system requirements

### Learning Resources

1. Apple TN3193: Using the Apple Intelligence APIs
2. FoundationModels Framework Documentation
3. ChatManager.swift (reference implementation)
4. Examples directory (practical patterns)

### Common Issues

| Issue | Solution | Reference |
|-------|----------|-----------|
| Device not eligible | Requires Apple Silicon | QUICKSTART.md |
| AI not enabled | Enable in Settings | README.md |
| Model not ready | Wait for download | README.md |
| Context overflow | Auto-handled or use `clear` | .agent-cli |
| Build errors | Check macOS version | build.sh |

## Project Statistics

- **Total Files**: 14 (CLI tool + config)
- **Code**: 371 lines (Swift)
- **Configuration**: 160 lines (YAML)
- **Documentation**: ~35KB (5 markdown files)
- **Examples**: 4 working scripts
- **Scripts**: 2 utility scripts

## Version Information

- **Created**: 2026-01-12
- **Framework**: FoundationModels
- **macOS**: 15.1+ required
- **Config Version**: 1.0.0
- **Status**: Production-ready with compatibility review needed

## Next Steps

1. **Try it**: `./applei-cli.swift "Hello"`
2. **Build it**: `./build.sh`
3. **Test it**: `./test.sh`
4. **Explore**: `cd examples`
5. **Review**: Read `.agent-cli` for compatibility

## Quick Command Reference

```bash
# Help
./applei-cli.swift --help

# Single query
./applei-cli.swift "What is Swift?"

# Interactive
./applei-cli.swift --interactive

# Model selection
./applei-cli.swift --model contentTagging "Categorize: AI article"

# Temperature
./applei-cli.swift --temperature 0.9 "Be creative"

# Build
./build.sh

# Test
./test.sh
```

## License & Attribution

- Based on Apple's FoundationModels framework
- Derived from ChatManager.swift implementation
- Created: 2026-01-12
- Refer to Apple's licensing for framework usage

---

**Need help?** Start with [QUICKSTART.md](QUICKSTART.md) for immediate answers or [README.md](README.md) for comprehensive documentation.
