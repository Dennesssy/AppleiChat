#!/bin/bash

echo "=== Test 1: First question ==="
./applei-cli "What is Swift?"

echo ""
echo "=== Test 2: Follow-up (should remember Test 1) ==="
./applei-cli "Tell me more about it"

echo ""
echo "=== Test 3: Reference from Test 1 ==="
./applei-cli "Why is it useful?"
