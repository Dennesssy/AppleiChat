//
//  applei-cli.swift
//  Applei-CLI
//
//  CLI tool for Apple Intelligence using FoundationModels framework
//
//  Usage:
//    ./applei-cli "Your prompt here"           # Single query mode
//    ./applei-cli --interactive                # Interactive mode
//    ./applei-cli --model general "Prompt"     # Specify model
//    ./applei-cli --temperature 0.8 "Prompt"   # Set temperature
//
//  Build instructions:
//    swiftc -o applei-cli applei-cli.swift -framework FoundationModels -framework Foundation
//    chmod +x applei-cli
//

import Foundation
import FoundationModels

// MARK: - Tool Definitions

struct FetchWebContent: Tool {
    let name = "fetch_web_content"
    let description = "Fetch and analyze web content from a URL"
    let parameters = FetchWebContentParameters()

    @Generable
    struct Arguments {
        @Guide(description: "The URL to fetch content from")
        let url: String
    }

    func call(arguments: Arguments) async throws -> String {
        let executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        let dir = executableURL.deletingLastPathComponent()
        let swiftfejsPath = dir.appendingPathComponent("swiftfejs").path

        guard FileManager.default.fileExists(atPath: swiftfejsPath) else {
            return "Error: SwiftFejs not found at \(swiftfejsPath)"
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: swiftfejsPath)
        process.arguments = [arguments.url, "--mode", "text", "--timeout", "15"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let content = String(data: data, encoding: .utf8) {
                return content
            }
        } catch {
            return "Error fetching URL: \(error.localizedDescription)"
        }

        return "Error: Failed to fetch content"
    }
}

struct SystemMonitor: Tool {
    let name = "system_monitor"
    let description = "Show system info: RAM, CPU, running processes"
    
    @Generable
    struct Arguments {}
    
    func call(arguments: Arguments) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/top")
        process.arguments = ["-l", "1", "-n", "10"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? "Error reading system info"
    }
}

struct ListProcesses: Tool {
    let name = "list_processes"
    let description = "List currently running processes on the system"
    
    @Generable
    struct Arguments {}
    
    func call(arguments: Arguments) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["aux"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return output.components(separatedBy: "\n").prefix(20).joined(separator: "\n")
    }
}

struct BashExecute: Tool {
    let name = "bash_execute"
    let description = "Execute a bash command and return output"
    
    @Generable
    struct Arguments {
        @Guide(description: "The bash command to execute")
        let command: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", arguments.command]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

struct ReadFile: Tool {
    let name = "read_file"
    let description = "Read contents of a text file"
    
    @Generable
    struct Arguments {
        @Guide(description: "Absolute path to the file")
        let path: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        try String(contentsOfFile: arguments.path, encoding: .utf8)
    }
}

struct AnalyzeProject: Tool {
    let name = "analyze_project"
    let description = "Read all Swift files in a directory for analysis"
    
    @Generable
    struct Arguments {
        @Guide(description: "Directory path to analyze")
        let path: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let files = try FileManager.default.contentsOfDirectory(atPath: arguments.path)
            .filter { $0.hasSuffix(".swift") }
            .prefix(10)
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            for file in files {
                group.addTask {
                    let content = try String(contentsOfFile: "\(arguments.path)/\(file)", encoding: .utf8)
                    return "=== \(file) ===\n\(content)\n"
                }
            }
            
            var result = ""
            for try await fileContent in group {
                result += fileContent
            }
            return result
        }
    }
}

struct EditFile: Tool {
    let name = "edit_file"
    let description = "Write or overwrite content to a file"
    
    @Generable
    struct Arguments {
        @Guide(description: "Absolute path to the file")
        let path: String
        @Guide(description: "New content to write to the file")
        let content: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        try arguments.content.write(toFile: arguments.path, atomically: true, encoding: .utf8)
        return "File updated successfully: \(arguments.path)"
    }
}

struct TaskState: Codable {
    let goal: String
    let completedSteps: [String]
    let remainingSteps: [String]
    let lastUpdated: String
    let contextResets: Int
}

struct ManageTaskState: Tool {
    let name = "manage_task_state"
    let description = "Save or load task progress for long-running multi-step tasks"
    
    @Generable
    struct Arguments {
        @Guide(description: "Action: 'save' or 'load'")
        let action: String
        @Guide(description: "Task goal (required for save)")
        let goal: String?
        @Guide(description: "Completed steps as comma-separated string (for save)")
        let completed: String?
        @Guide(description: "Remaining steps as comma-separated string (for save)")
        let remaining: String?
    }
    
    func call(arguments: Arguments) async throws -> String {
        let stateFile = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/AppleiChat/task_state.json")
        
        if arguments.action == "load" {
            guard FileManager.default.fileExists(atPath: stateFile.path) else {
                return "No saved task state found"
            }
            let data = try Data(contentsOf: stateFile)
            let state = try JSONDecoder().decode(TaskState.self, from: data)
            return """
            Task Goal: \(state.goal)
            Completed: \(state.completedSteps.joined(separator: ", "))
            Remaining: \(state.remainingSteps.joined(separator: ", "))
            Context Resets: \(state.contextResets)
            """
        } else if arguments.action == "save" {
            guard let goal = arguments.goal else {
                return "Error: goal required for save"
            }
            
            let completed = arguments.completed?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
            let remaining = arguments.remaining?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
            
            var resets = 0
            if FileManager.default.fileExists(atPath: stateFile.path) {
                let data = try Data(contentsOf: stateFile)
                let oldState = try JSONDecoder().decode(TaskState.self, from: data)
                resets = oldState.contextResets
            }
            
            let state = TaskState(
                goal: goal,
                completedSteps: completed,
                remainingSteps: remaining,
                lastUpdated: ISO8601DateFormatter().string(from: Date()),
                contextResets: resets
            )
            
            try FileManager.default.createDirectory(at: stateFile.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(state)
            try data.write(to: stateFile)
            
            return "Task state saved: \(completed.count) completed, \(remaining.count) remaining"
        }
        
        return "Invalid action. Use 'save' or 'load'"
    }
}

struct BashExecutor {
    static let shared = BashExecutor()
    
    func execute(_ command: String, timeoutSeconds: Double = 10.0) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

struct FetchWebContentParameters: Encodable {}

// MARK: - Configuration

struct CLIConfig {
    var modelUseCase: ModelUseCase = .general
    var temperature: Double = 0.3
    var maxTokens: Int? = nil
    var interactive: Bool = false
    var fetchUrl: String? = nil
    var systemInstructions: String = """
    You are a helpful AI assistant with system access. When users ask you to perform actions:
    - Use bash_execute for file operations, directory listings, or system commands
    - Use fetch_web_content to retrieve and analyze web pages
    - Use list_processes to show running processes
    
    For multi-step tasks:
    - Load previous progress at start: manage_task_state(action: "load")
    - Save progress after each major step: manage_task_state(action: "save", goal: "...", completed: "step1,step2", remaining: "step3,step4")
    - Check saved state before starting to avoid repeating work
    
    Prefer taking action over explaining. Execute commands directly rather than describing how to do them.
    """

    enum ModelUseCase: String {
        case general
        case contentTagging

        var systemModel: SystemLanguageModel {
            switch self {
            case .general:
                return SystemLanguageModel(useCase: .general)
            case .contentTagging:
                return SystemLanguageModel(useCase: .contentTagging)
            }
        }
    }
}

// MARK: - CLI Manager

class AppleiCLI {
    private var session: LanguageModelSession?
    private var model: SystemLanguageModel
    private var config: CLIConfig
    private var messageCount: Int = 0

    init(config: CLIConfig) {
        self.config = config
        self.model = config.modelUseCase.systemModel
        self.initializeSession()
    }

    private func initializeSession() {
        let availability = model.availability

        switch availability {
        case .available:
            let fetchTool = FetchWebContent()
            let monitorTool = SystemMonitor()
            let processTool = ListProcesses()
            let bashTool = BashExecute()
            let readTool = ReadFile()
            let projectTool = AnalyzeProject()
            let editTool = EditFile()
            let taskTool = ManageTaskState()
            session = LanguageModelSession(
                model: model,
                tools: [fetchTool, monitorTool, processTool, bashTool, readTool, projectTool, editTool, taskTool],
                instructions: config.systemInstructions
            )
            // Prewarm session to reduce latency
            Task {
                await prewarmSession()
            }
        case .unavailable(.deviceNotEligible):
            printError("Device not eligible for Apple Intelligence")
            exit(1)
        case .unavailable(.appleIntelligenceNotEnabled):
            printError("Apple Intelligence not enabled. Enable in Settings > Apple Intelligence & Siri")
            exit(1)
        case .unavailable(.modelNotReady):
            printError("Model not ready. Please wait for download to complete")
            exit(1)
        case .unavailable:
            printError("Model unavailable. Check your settings")
            exit(1)
        }
    }

    private func prewarmSession() async {
        guard let session = session else { return }
        session.prewarm(promptPrefix: nil)
    }

    // Single prompt mode
    func query(_ prompt: String) async {
        guard let session = session else {
            printError("Session not initialized")
            return
        }

        do {
            let options = GenerationOptions(temperature: config.temperature)
            // streamResponse automatically maintains conversation history in the session
            let stream = session.streamResponse(to: prompt, options: options)

            var fullResponse = ""

            for try await partial in stream {
                if fullResponse.isEmpty {
                    print("\n", terminator: "")
                }

                let newContent = String(partial.content.dropFirst(fullResponse.count))
                print(newContent, terminator: "")
                fflush(stdout)

                fullResponse = partial.content
            }

            print("\n")

        } catch let error as LanguageModelSession.GenerationError {
            handleGenerationError(error)
        } catch {
            printError("Error: \(error.localizedDescription)")
        }
    }

    // Interactive mode
    func interactive() async {
        printInfo("Applei CLI - Interactive Mode")
        printInfo("Press Ctrl+C to exit or type 'exit'/'quit'\n")

        // Handle Ctrl+C gracefully
        signal(SIGINT) { _ in
            print("\n")
            print("\u{001B}[36m[INFO]\u{001B}[0m Goodbye!")
            exit(0)
        }

        while true {
            print("\n> ", terminator: "")
            fflush(stdout)

            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }

            if input.isEmpty {
                continue
            }

            // Check for exit command
            let command = input.lowercased()
            if command == "exit" || command == "quit" {
                printInfo("Goodbye!")
                return
            }

            await query(input)
        }
    }



    private func handleGenerationError(_ error: LanguageModelSession.GenerationError) {
        switch error {
        case .exceededContextWindowSize:
            printWarning("Context window exceeded. Creating new session with recent context...")

            if let originalSession = session {
                session = newContextualSession(from: originalSession)
                Task {
                    await prewarmSession()
                }
            }

            messageCount = 0

        case .refusal(_, _):
            printWarning("Model refused to generate response")

        case .assetsUnavailable:
            printError("Required assets are unavailable")

        case .guardrailViolation:
            printWarning("Response violated safety guardrails")

        case .unsupportedGuide:
            printError("Unsupported generation guide specified")

        case .unsupportedLanguageOrLocale:
            printError("Unsupported language or locale")

        case .decodingFailure:
            printError("Failed to decode model response")

        case .rateLimited:
            printWarning("API rate limit exceeded. Please retry later")

        case .concurrentRequests:
            printWarning("Too many concurrent requests. Please wait")

        @unknown default:
            printError("Unexpected generation error occurred")
        }
    }

    private func newContextualSession(from originalSession: LanguageModelSession, keepRecent count: Int = 6) -> LanguageModelSession {
        let allEntries = originalSession.transcript
        
        guard !allEntries.isEmpty else {
            return LanguageModelSession(
                model: model,
                tools: [FetchWebContent(), SystemMonitor(), ListProcesses(), BashExecute(), ReadFile(), AnalyzeProject(), EditFile(), ManageTaskState()],
                instructions: config.systemInstructions
            )
        }
        
        // Increment context reset counter in task state
        let stateFile = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/AppleiChat/task_state.json")
        if FileManager.default.fileExists(atPath: stateFile.path),
           let data = try? Data(contentsOf: stateFile),
           var state = try? JSONDecoder().decode(TaskState.self, from: data) {
            let updatedState = TaskState(
                goal: state.goal,
                completedSteps: state.completedSteps,
                remainingSteps: state.remainingSteps,
                lastUpdated: ISO8601DateFormatter().string(from: Date()),
                contextResets: state.contextResets + 1
            )
            if let encoded = try? JSONEncoder().encode(updatedState) {
                try? encoded.write(to: stateFile)
            }
        }
        
        var condensedEntries: [Transcript.Entry] = []
        
        if let first = allEntries.first {
            condensedEntries.append(first)
        }
        
        let recentEntries = allEntries.suffix(count)
        if recentEntries.first != allEntries.first {
            condensedEntries.append(contentsOf: recentEntries)
        }

        let condensedTranscript = Transcript(entries: condensedEntries)
        return LanguageModelSession(transcript: condensedTranscript)
    }

    // MARK: - Web Content Fetching

    func fetchWebContent(_ urlString: String) -> String? {
        let executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        let dir = executableURL.deletingLastPathComponent()
        let swiftfejsPath = dir.appendingPathComponent("swiftfejs").path

        guard FileManager.default.fileExists(atPath: swiftfejsPath) else {
            printWarning("SwiftFejs not found at \(swiftfejsPath)")
            return nil
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: swiftfejsPath)
        process.arguments = [urlString, "--mode", "text", "--timeout", "15"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let content = String(data: data, encoding: .utf8) {
                return content
            }
        } catch {
            printError("Failed to fetch URL: \(error.localizedDescription)")
        }

        return nil
    }

    // MARK: - Utility Functions

    private func printError(_ message: String) {
        fputs("\u{001B}[31m[ERROR]\u{001B}[0m \(message)\n", stderr)
    }

    private func printWarning(_ message: String) {
        fputs("\u{001B}[33m[WARNING]\u{001B}[0m \(message)\n", stderr)
    }

    private func printInfo(_ message: String) {
        print("\u{001B}[36m[INFO]\u{001B}[0m \(message)")
    }
}

// MARK: - Argument Parser

struct ArgumentParser {
    static func parse() -> (config: CLIConfig, prompt: String?) {
        var config = CLIConfig()
        var prompt: String? = nil
        var args = CommandLine.arguments
        args.removeFirst() // Remove program name

        var i = 0
        while i < args.count {
            let arg = args[i]

            switch arg {
            case "--interactive", "-i":
                config.interactive = true
                i += 1

            case "--model", "-m":
                if i + 1 < args.count {
                    let modelStr = args[i + 1]
                    if let modelCase = CLIConfig.ModelUseCase(rawValue: modelStr) {
                        config.modelUseCase = modelCase
                    } else {
                        fputs("Unknown model: \(modelStr). Using default (general)\n", stderr)
                    }
                    i += 2
                } else {
                    fputs("--model requires a value\n", stderr)
                    i += 1
                }

            case "--temperature", "-t":
                if i + 1 < args.count {
                    if let temp = Double(args[i + 1]) {
                        config.temperature = max(0.0, min(1.0, temp))
                    }
                    i += 2
                } else {
                    fputs("--temperature requires a value\n", stderr)
                    i += 1
                }

            case "--system", "-s":
                if i + 1 < args.count {
                    config.systemInstructions = args[i + 1]
                    i += 2
                } else {
                    fputs("--system requires a value\n", stderr)
                    i += 1
                }

            case "--fetch-url":
                if i + 1 < args.count {
                    config.fetchUrl = args[i + 1]
                    i += 2
                } else {
                    fputs("--fetch-url requires a URL\n", stderr)
                    i += 1
                }

            case "--help", "-h":
                printUsage()
                exit(0)

            default:
                // Treat as prompt
                if prompt == nil {
                    prompt = arg
                } else {
                    prompt! += " " + arg
                }
                i += 1
            }
        }

        return (config, prompt)
    }

    static func printUsage() {
        print("""

        Applei CLI - Apple Intelligence Command Line Interface

        Usage:
          applei-cli [options] "prompt"           Single query mode
          applei-cli --interactive                Interactive mode
          applei-cli --fetch-url <url> "analyze"  Fetch and analyze web content

        Options:
          -i, --interactive              Start interactive mode
          -m, --model <model>            Select model (general, contentTagging)
          -t, --temperature <value>      Set temperature (0.0-1.0, default: 0.7)
          -s, --system <instructions>    Custom system instructions
          --fetch-url <url>              Fetch web content via SwiftFejs
          -h, --help                     Show this help message

        Examples:
          applei-cli "What is Swift?"
          applei-cli --fetch-url "https://example.com" "summarize this"
          applei-cli --interactive

        Note: Requires macOS 15.1+ and Apple Intelligence enabled

        """)
    }
}

// MARK: - Main Entry Point

@main
struct Main {
    static func main() async {
        let (config, prompt) = ArgumentParser.parse()

        let cli = AppleiCLI(config: config)

        if config.interactive {
            await cli.interactive()
        } else if let url = config.fetchUrl {
            // Fetch URL mode
            if let content = cli.fetchWebContent(url) {
                let analysisPrompt = prompt ?? "Please analyze and summarize this web content."
                let fullPrompt = "Web Content:\n\n\(content)\n\nAnalysis Request: \(analysisPrompt)"
                await cli.query(fullPrompt)
            }
        } else if let prompt = prompt {
            await cli.query(prompt)
        } else {
            ArgumentParser.printUsage()
            exit(1)
        }
    }
}
