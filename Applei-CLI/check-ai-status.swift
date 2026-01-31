#!/usr/bin/env swift
import Foundation
import FoundationModels

let model = SystemLanguageModel(useCase: .general)
let availability = model.availability

print("Apple Intelligence Status Check")
print("================================")

switch availability {
case .available:
    print("✅ Status: AVAILABLE")
    print("Apple Intelligence is enabled and ready to use")

case .unavailable(.deviceNotEligible):
    print("❌ Status: DEVICE NOT ELIGIBLE")
    print("This device doesn't support Apple Intelligence")
    print("Requires: Apple Silicon (M1 or newer)")

case .unavailable(.appleIntelligenceNotEnabled):
    print("⚠️  Status: NOT ENABLED")
    print("Apple Intelligence is not enabled on this device")
    print("Solution: System Settings → Apple Intelligence & Siri → Enable")

case .unavailable(.modelNotReady):
    print("⏳ Status: MODEL DOWNLOADING")
    print("The AI model is still downloading")
    print("Check: System Settings → Apple Intelligence & Siri")

case .unavailable:
    print("❌ Status: UNAVAILABLE")
    print("Apple Intelligence is unavailable for unknown reason")
}

print("\nSystem Info:")
print("macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)")
