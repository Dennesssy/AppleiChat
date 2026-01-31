#!/bin/bash
# AppleiCLI Diagnostic Script

echo "================================================"
echo "AppleiCLI Diagnostic Report"
echo "================================================"
echo ""

# Check binary
echo "1. CLI Binary Status:"
if [ -f "./applei-cli" ]; then
    echo "   ✅ Binary exists"
    file ./applei-cli | grep -q "executable" && echo "   ✅ Executable format valid" || echo "   ❌ Not a valid executable"
    ls -lh ./applei-cli | awk '{print "   Size: " $5}'
else
    echo "   ❌ Binary not found"
fi
echo ""

# Check SwiftFejs
echo "2. SwiftFejs Integration:"
SWIFTFEJS_PATH="/Users/denn/ML/Projecti/SwiftFejs/swiftfejs"
if [ -f "$SWIFTFEJS_PATH" ]; then
    echo "   ✅ SwiftFejs binary exists"
    ls -lh "$SWIFTFEJS_PATH" | awk '{print "   Size: " $5}'
else
    echo "   ❌ SwiftFejs not found at $SWIFTFEJS_PATH"
fi
echo ""

# Check Gemini
echo "3. Gemini Integration:"
if command -v gemini &> /dev/null; then
    echo "   ✅ Gemini CLI found: $(which gemini)"
else
    echo "   ❌ Gemini CLI not found"
fi
echo ""

# Check Apple Intelligence availability
echo "4. Apple Intelligence Status:"
swift check-ai-status.swift 2>&1 | grep -E "✅|❌|⚠️" | head -3
echo ""

# Test Gemini
echo "5. Testing Gemini Integration:"
GEMINI_TEST=$(./applei-cli --ask-gemini "What is 1+1?" 2>&1)
if echo "$GEMINI_TEST" | grep -q "GEMINI"; then
    echo "   ✅ Gemini query successful"
    echo "$GEMINI_TEST" | grep "GEMINI"
else
    echo "   ❌ Gemini query failed"
fi
echo ""

# Test Apple Intelligence
echo "6. Testing Apple Intelligence:"
AI_TEST=$(timeout 10 ./applei-cli "Say 'working' in one word" 2>&1)
if echo "$AI_TEST" | grep -iq "working"; then
    echo "   ✅ Apple Intelligence query successful"
else
    echo "   ❌ Apple Intelligence query failed"
    if echo "$AI_TEST" | grep -q "ERROR"; then
        echo "   Error: $(echo "$AI_TEST" | grep ERROR)"
    fi
fi
echo ""

# Check zsh alias
echo "7. Shell Alias Configuration:"
if grep -q "Applei.*applei-cli.*interactive" ~/.zshrc; then
    echo "   ✅ Applei alias configured in ~/.zshrc"
    grep "Applei" ~/.zshrc
else
    echo "   ❌ Applei alias not found in ~/.zshrc"
fi
echo ""

echo "================================================"
echo "Diagnostic Complete"
echo "================================================"
echo ""
echo "Working Features:"
echo "  - Gemini queries: Use --ask-gemini flag"
echo "  - Interactive mode: Use --interactive flag"
echo ""
echo "If Apple Intelligence fails:"
echo "  1. sudo killall modelmanagerd"
echo "  2. Wait 10 seconds and retry"
echo "  3. Check: System Settings → Apple Intelligence"
echo ""
