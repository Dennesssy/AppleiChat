#!/bin/bash

#
# Example: Content Tagging
# Use the contentTagging model for categorization
#

CLI="../applei-cli.swift"

echo "Content Tagging Examples"
echo "========================"
echo ""

# Articles to categorize
declare -a articles=(
    "Machine learning algorithms for image recognition"
    "Swift programming best practices and patterns"
    "Renewable energy solutions for sustainable future"
    "iOS app development with SwiftUI framework"
    "Climate change impact on global ecosystems"
)

# Tag each article
for article in "${articles[@]}"; do
    echo "Content: $article"
    echo "Tags:"
    "$CLI" --model contentTagging "Categorize and tag this content: $article"
    echo ""
    echo "---"
    echo ""
done

echo "Tagging complete!"
