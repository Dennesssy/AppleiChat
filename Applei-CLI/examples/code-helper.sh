#!/bin/bash

#
# Example: Code Helper
# Use CLI as a coding assistant
#

CLI="../applei-cli.swift"

echo "Code Helper - Swift Programming Assistant"
echo "=========================================="
echo ""

# System instructions for code help
SYSTEM="You are an expert Swift developer. Provide concise, practical code examples and explanations."

# Code questions
echo "1. Async/Await Example"
echo "---"
"$CLI" --system "$SYSTEM" "Show me a simple async/await example in Swift"
echo ""
echo ""

echo "2. SwiftUI View Example"
echo "---"
"$CLI" --system "$SYSTEM" "Show me a basic SwiftUI button with action"
echo ""
echo ""

echo "3. Error Handling"
echo "---"
"$CLI" --system "$SYSTEM" "Explain Swift error handling with do-catch in one paragraph"
echo ""
echo ""

echo "Code helper examples complete!"
