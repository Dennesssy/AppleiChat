# Xcode SDK Exploration Guide

**Last Updated:** 2026-01-12
**macOS Version:** 26.2
**Xcode Version:** Latest Beta

## Overview

This guide documents methods for discovering and exploring private/undocumented Apple frameworks, specifically focusing on the FoundationModels framework introduced in macOS 26.2 for Apple Intelligence features.

---

## 1. Finding Framework Locations

### Primary SDK Location
```bash
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/
```

### FoundationModels Framework Path
```bash
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/FoundationModels.framework
```

### Quick Navigation Commands
```bash
# Navigate to SDK frameworks
cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/

# List all frameworks
ls -la | grep -i "foundation\|intelligence\|model"

# Find specific framework
find . -name "FoundationModels.framework" -type d
```

---

## 2. Discovering API Interfaces

### SwiftInterface Files

The key to understanding private frameworks is the `.swiftinterface` file, which contains the public interface definition.

#### Location Pattern
```bash
{FrameworkName}.framework/Modules/{FrameworkName}.swiftmodule/{architecture}-apple-macos.swiftinterface
```

#### FoundationModels SwiftInterface
```bash
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/FoundationModels.framework/Modules/FoundationModels.swiftmodule/arm64e-apple-macos.swiftinterface
```

#### Viewing the Interface
```bash
# Read the entire interface
cat /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/FoundationModels.framework/Modules/FoundationModels.swiftmodule/arm64e-apple-macos.swiftinterface

# Search for specific APIs
grep -i "Tool" arm64e-apple-macos.swiftinterface
grep -i "Cloud" arm64e-apple-macos.swiftinterface
grep -i "Model" arm64e-apple-macos.swiftinterface
```

---

## 3. Key Search Techniques

### Using Grep for API Discovery

```bash
# Navigate to the framework module directory
cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/FoundationModels.framework/Modules/FoundationModels.swiftmodule/

# Search for protocols
grep "protocol " arm64e-apple-macos.swiftinterface

# Search for classes
grep "class " arm64e-apple-macos.swiftinterface

# Search for specific features (case-insensitive)
grep -i "tool" arm64e-apple-macos.swiftinterface
grep -i "function" arm64e-apple-macos.swiftinterface
grep -i "cloud" arm64e-apple-macos.swiftinterface
grep -i "private" arm64e-apple-macos.swiftinterface

# Search with context (show surrounding lines)
grep -A 5 -B 5 "protocol Tool" arm64e-apple-macos.swiftinterface

# Extract all public APIs
grep "public " arm64e-apple-macos.swiftinterface
```

### Advanced Search Patterns

```bash
# Find all function definitions
grep -E "func [a-zA-Z]+" arm64e-apple-macos.swiftinterface

# Find all property definitions
grep -E "var [a-zA-Z]+:" arm64e-apple-macos.swiftinterface

# Find initializers
grep "init(" arm64e-apple-macos.swiftinterface

# Find async/await functions
grep "async" arm64e-apple-macos.swiftinterface

# Find throwing functions
grep "throws" arm64e-apple-macos.swiftinterface
```

---

## 4. Key Discoveries in FoundationModels

### Tool Protocol Support

The framework includes comprehensive tool calling support:

```swift
// Core Tool Protocol
protocol Tool {
    // Custom tool implementations
}

// Tool-related types
- ToolCalls: Represents function/tool call requests
- ToolOutput: Results from tool execution
- ToolDefinition: Schema/definition for tools
- ToolChoice: Strategy for tool selection
```

### Model Access APIs

```swift
// SystemLanguageModel
// Primary interface for on-device language models
// NOTE: Only exposes on-device models, no PCC (Private Cloud Compute) API

// Usage pattern:
let model = SystemLanguageModel()
// Interact with on-device Apple Intelligence models
```

### Cloud/PCC Limitations

**Important Discovery:** The current FoundationModels framework does NOT expose:
- Private Cloud Compute (PCC) APIs
- Cloud-based model endpoints
- Server-side Apple Intelligence features

All APIs are focused on on-device processing only.

---

## 5. CLI Access and Compilation

### Swift Compiler Integration

You can use the Swift compiler directly to work with these frameworks:

```bash
# Compile with FoundationModels framework
swiftc -framework FoundationModels your_file.swift

# Interactive Swift REPL with framework
swift -F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/

# Import in Swift code
import FoundationModels
```

### Testing Framework Availability

```bash
# Quick test to see if framework is accessible
cat > test.swift << 'EOF'
import FoundationModels
print("FoundationModels framework loaded successfully")
EOF

swiftc -framework FoundationModels test.swift -o test
./test
rm test test.swift
```

---

## 6. Framework Exploration Workflow

### Step-by-Step Process

1. **Locate the Framework**
   ```bash
   cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/
   ls -la | grep -i {framework_name}
   ```

2. **Find SwiftInterface File**
   ```bash
   cd {FrameworkName}.framework/Modules/{FrameworkName}.swiftmodule/
   ls -la
   # Look for: arm64e-apple-macos.swiftinterface or arm64-apple-macos.swiftinterface
   ```

3. **Initial Survey**
   ```bash
   # Count total lines
   wc -l arm64e-apple-macos.swiftinterface

   # Get overview of public APIs
   grep "public " arm64e-apple-macos.swiftinterface | head -20
   ```

4. **Search for Specific Features**
   ```bash
   # Replace {FEATURE} with what you're looking for
   grep -i "{FEATURE}" arm64e-apple-macos.swiftinterface
   ```

5. **Extract Relevant Sections**
   ```bash
   # Get protocol definitions
   grep -A 20 "protocol " arm64e-apple-macos.swiftinterface

   # Get class definitions
   grep -A 20 "class " arm64e-apple-macos.swiftinterface
   ```

6. **Test in Code**
   - Create small test Swift file
   - Import framework
   - Try discovered APIs
   - Check compiler errors for hints

---

## 7. Architecture Considerations

### SwiftInterface Files by Architecture

Different CPU architectures may have different interface files:

```bash
# Apple Silicon (M-series chips)
arm64-apple-macos.swiftinterface
arm64e-apple-macos.swiftinterface  # Enhanced security features

# Intel Macs (if supported)
x86_64-apple-macos.swiftinterface
```

### Checking All Architectures

```bash
cd {Framework}.framework/Modules/{Framework}.swiftmodule/
ls -la *.swiftinterface
```

---

## 8. Common Frameworks to Explore

### AI/ML Related
- **FoundationModels** - Apple Intelligence language models
- **MLCompute** - Machine learning computation
- **CoreML** - Core machine learning
- **NaturalLanguage** - Text processing

### Privacy/Security Related
- **PrivateCloudCompute** - PCC infrastructure (if available)
- **CryptoKit** - Cryptographic operations

### System Integration
- **AppIntents** - Siri/Shortcuts integration
- **SiriKit** - Siri extensions

---

## 9. Best Practices

### Do's ✅
- Always check multiple architecture files
- Use grep with context (-A, -B flags) for better understanding
- Test APIs in isolated test projects first
- Document undocumented behavior you discover
- Check for availability attributes (@available)

### Don'ts ❌
- Don't rely on private APIs for production apps (App Store rejection)
- Don't assume APIs are stable (they can change between OS versions)
- Don't ship apps using undocumented frameworks without SPI entitlements
- Don't forget to check if public alternatives exist

---

## 10. Troubleshooting

### Framework Not Found
```bash
# Verify SDK installation
xcode-select -p
ls -la /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
```

### SwiftInterface File Missing
```bash
# Some frameworks use .tbd (text-based stub) files instead
ls -la {Framework}.framework/
# Look for Versions/A/Modules/ or just Modules/
```

### Compilation Errors
```bash
# Check framework search paths
swiftc -F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/ -framework {Framework} test.swift

# Use verbose mode for debugging
swiftc -v -framework {Framework} test.swift
```

---

## 11. Useful Commands Reference

```bash
# Quick framework search
find /Applications/Xcode.app/Contents/Developer -name "*.framework" -type d | grep -i {keyword}

# Extract all protocol names from interface
grep -o "protocol [A-Za-z0-9_]*" arm64e-apple-macos.swiftinterface

# Extract all class names
grep -o "class [A-Za-z0-9_]*" arm64e-apple-macos.swiftinterface

# Count public vs internal APIs
echo "Public:" && grep -c "public " arm64e-apple-macos.swiftinterface
echo "Internal:" && grep -c "internal " arm64e-apple-macos.swiftinterface

# Find async/await patterns
grep -E "(async|await)" arm64e-apple-macos.swiftinterface

# Find Combine publishers
grep -i "publisher" arm64e-apple-macos.swiftinterface

# Find SwiftUI views
grep -i "view" arm64e-apple-macos.swiftinterface
```

---

## 12. Related Resources

### Apple Developer Documentation
- [Swift Evolution](https://apple.github.io/swift-evolution/)
- [Swift Forums](https://forums.swift.org/)
- [WWDC Videos](https://developer.apple.com/videos/)

### Community Resources
- GitHub issues tracking private API behavior
- Reverse engineering blogs
- iOS/macOS developer communities

### Tools
- **Hopper Disassembler** - Binary analysis
- **class-dump** - Objective-C header generation
- **swift-interface-extractor** - Community tools
- **nm** - Symbol listing (built-in)

---

## 13. Example: FoundationModels Exploration Session

### Complete workflow from discovery to usage:

```bash
# 1. Navigate to framework
cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/FoundationModels.framework

# 2. Find interface
cd Modules/FoundationModels.swiftmodule/

# 3. Search for tool support
grep -i "tool" arm64e-apple-macos.swiftinterface
# Output shows: Tool protocol, ToolCalls, ToolOutput, ToolDefinition

# 4. Get protocol details
grep -A 30 "protocol Tool" arm64e-apple-macos.swiftinterface

# 5. Check for cloud features
grep -i "cloud\|pcc\|private" arm64e-apple-macos.swiftinterface
# Result: No PCC API exposed

# 6. Find model access
grep -i "SystemLanguageModel" arm64e-apple-macos.swiftinterface
# Result: On-device only

# 7. Create test file
cat > ~/test_foundation.swift << 'EOF'
import FoundationModels

// Test basic import
print("FoundationModels available")

// Try to access discovered APIs
// let model = SystemLanguageModel() // Uncomment to test
EOF

# 8. Compile and test
swiftc -framework FoundationModels ~/test_foundation.swift -o ~/test_foundation
~/test_foundation

# 9. Clean up
rm ~/test_foundation ~/test_foundation.swift
```

---

## 14. Limitations and Caveats

### Current Limitations
- **No PCC Access**: Private Cloud Compute APIs not exposed in SDK
- **On-Device Only**: SystemLanguageModel only supports local models
- **Beta Status**: APIs may change in future macOS versions
- **Entitlements Required**: Some features need special app entitlements
- **Sandboxing**: App Sandbox may restrict framework access

### Platform Requirements
- **macOS 26.2+** for FoundationModels
- **Apple Silicon** recommended (some features M-series only)
- **Xcode Beta** for latest framework access
- **Developer Account** for certain entitlements

---

## Conclusion

SDK exploration through SwiftInterface files is a powerful technique for:
- Understanding undocumented frameworks
- Discovering new APIs before official documentation
- Learning framework architecture and design patterns
- Prototyping with cutting-edge features

Always remember to:
- Respect Apple's terms and conditions
- Use private APIs responsibly (research/education only)
- Check for public alternatives before using private APIs
- Stay updated with official documentation releases

---

**Questions or Updates?**
Document your findings and contribute to community knowledge sharing while respecting Apple's intellectual property and developer agreements.
