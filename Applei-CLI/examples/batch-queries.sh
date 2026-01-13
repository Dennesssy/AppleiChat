#!/bin/bash

#
# Example: Batch Queries
# Process multiple questions in sequence
#

CLI="../applei-cli.swift"

echo "Running batch queries..."
echo ""

# Array of questions
questions=(
    "What is Swift?"
    "What is SwiftUI?"
    "What is FoundationModels?"
    "What is Apple Intelligence?"
)

# Process each question
for i in "${!questions[@]}"; do
    echo "[$((i+1))/${#questions[@]}] Question: ${questions[$i]}"
    echo "---"
    "$CLI" "${questions[$i]}"
    echo ""
    echo ""
done

echo "Batch processing complete!"
