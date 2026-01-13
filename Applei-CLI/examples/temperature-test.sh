#!/bin/bash

#
# Example: Temperature Comparison
# See how temperature affects output creativity
#

CLI="../applei-cli.swift"

PROMPT="Tell me about Swift in one sentence"

echo "Temperature Comparison Test"
echo "============================"
echo "Prompt: $PROMPT"
echo ""

# Test different temperatures
for temp in 0.1 0.5 0.9; do
    echo "Temperature: $temp"
    echo "---"
    "$CLI" --temperature "$temp" "$PROMPT"
    echo ""
    echo ""
done

echo "Temperature test complete!"
echo ""
echo "Observations:"
echo "- Low temp (0.1): More consistent, factual"
echo "- Medium temp (0.5): Balanced"
echo "- High temp (0.9): More creative, varied"
