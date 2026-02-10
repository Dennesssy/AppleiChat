#!/bin/bash
cd /Users/denn/Desktop/Xcode/AppleiChat/Applei-CLI

# Build
swiftc -parse-as-library -o applei-cli applei-cli.swift -framework FoundationModels -framework Foundation -O

# 5 questions
./applei-cli "Define URLSession API in Swift"
./applei-cli "Define Codable protocol in Swift"
./applei-cli "Define async/await in Swift"
./applei-cli "Define Combine framework in Swift"
./applei-cli "Define SwiftUI View protocol"
