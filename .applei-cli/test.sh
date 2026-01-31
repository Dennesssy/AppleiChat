#!/bin/bash

#
# Test script for Applei CLI
# Runs basic tests to verify functionality
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$SCRIPT_DIR/applei-cli.swift"

echo "Testing Applei CLI..."
echo "===================="
echo ""

# Test 1: Help command
echo "Test 1: Help command"
echo "--------------------"
"$CLI" --help
echo ""

# Test 2: Simple query
echo "Test 2: Simple query"
echo "--------------------"
echo "Query: 'What is 2+2?'"
"$CLI" "What is 2+2?"
echo ""

# Test 3: Model selection
echo "Test 3: Model selection"
echo "--------------------"
echo "Query with general model"
"$CLI" --model general "Hello"
echo ""

# Test 4: Temperature control
echo "Test 4: Temperature control"
echo "--------------------"
echo "Query with temperature 0.3"
"$CLI" --temperature 0.3 "Count to 3"
echo ""

echo "===================="
echo "All tests completed!"
echo ""
echo "To test interactive mode manually:"
echo "  $CLI --interactive"
echo ""
