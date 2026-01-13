#!/bin/bash

#
# Build script for Applei CLI
# Compiles the Swift CLI tool with FoundationModels framework
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/applei-cli.swift"
OUTPUT_FILE="$SCRIPT_DIR/applei-cli"

echo "Building Applei CLI..."
echo "Source: $SOURCE_FILE"
echo "Output: $OUTPUT_FILE"
echo ""

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file not found: $SOURCE_FILE"
    exit 1
fi

# Check macOS version (requires 15.1+)
MACOS_VERSION=$(sw_vers -productVersion)
echo "macOS Version: $MACOS_VERSION"

# Compile
echo "Compiling..."
swiftc -o "$OUTPUT_FILE" "$SOURCE_FILE" \
    -framework FoundationModels \
    -framework Foundation \
    -O

# Make executable
chmod +x "$OUTPUT_FILE"

echo ""
echo "Build successful!"
echo "Binary location: $OUTPUT_FILE"
echo ""
echo "Usage:"
echo "  $OUTPUT_FILE \"Your prompt here\""
echo "  $OUTPUT_FILE --interactive"
echo "  $OUTPUT_FILE --help"
echo ""
echo "To install globally (optional):"
echo "  sudo cp $OUTPUT_FILE /usr/local/bin/"
echo ""
