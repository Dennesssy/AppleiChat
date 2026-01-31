#!/usr/bin/env swift
import Foundation
import FoundationModels

print("Testing Apple Intelligence Session...")

let model = SystemLanguageModel(useCase: .general)
print("✅ Model created")

let availability = model.availability
guard case .available = availability else {
    print("❌ Model not available")
    exit(1)
}
print("✅ Model available")

let session = LanguageModelSession(
    model: model,
    tools: [],
    instructions: "You are a helpful assistant."
)
print("✅ Session created")

Task {
    do {
        print("Sending query...")
        let options = GenerationOptions(temperature: 0.7)
        let stream = session.streamResponse(to: "What is 2+2?", options: options)

        print("\nResponse: ", terminator: "")
        for try await partial in stream {
            print(partial.content, terminator: "")
            fflush(stdout)
        }
        print("\n\n✅ Query successful!")
        exit(0)
    } catch {
        print("\n❌ Error: \(error)")
        print("Error type: \(type(of: error))")
        exit(1)
    }
}

RunLoop.main.run()
