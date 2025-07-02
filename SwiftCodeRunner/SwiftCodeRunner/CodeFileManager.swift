import Foundation

struct CodeFile {
    let name: String
    let content: String
    let dateCreated: Date
    let dateModified: Date
}

class CodeFileManager {
    static let shared = CodeFileManager()
    
    private init() {}
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var codeDirectory: URL {
        let codeDir = documentsDirectory.appendingPathComponent("SwiftCode")
        if !FileManager.default.fileExists(atPath: codeDir.path) {
            try? FileManager.default.createDirectory(at: codeDir, withIntermediateDirectories: true)
        }
        return codeDir
    }
    
    // MARK: - File Operations
    
    func saveCodeFile(name: String, content: String) throws {
        let fileName = name.hasSuffix(".swift") ? name : "\(name).swift"
        let fileURL = codeDirectory.appendingPathComponent(fileName)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func loadCodeFiles() -> [CodeFile] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: codeDirectory, includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey]) else {
            return []
        }
        
        return files.compactMap { url in
            guard url.pathExtension == "swift" else { return nil }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                let creationDate = attributes[.creationDate] as? Date ?? Date()
                let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                
                return CodeFile(
                    name: url.deletingPathExtension().lastPathComponent,
                    content: content,
                    dateCreated: creationDate,
                    dateModified: modificationDate
                )
            } catch {
                print("Error loading file \(url.lastPathComponent): \(error)")
                return nil
            }
        }.sorted { $0.dateModified > $1.dateModified }
    }
    
    func deleteCodeFile(name: String) throws {
        let fileName = name.hasSuffix(".swift") ? name : "\(name).swift"
        let fileURL = codeDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func codeFileExists(name: String) -> Bool {
        let fileName = name.hasSuffix(".swift") ? name : "\(name).swift"
        let fileURL = codeDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func createSampleFiles() {
        let sampleCodes = [
            ("Hello World", """
                import Foundation

                print("Hello, World!")
                print("Welcome to Swift Code Runner!")
                
                let message = "This is a sample Swift program"
                print(message)
                """),
            ("Variables and Constants", """
                import Foundation

                // Constants
                let pi = 3.14159
                let appName = "Swift Code Runner"

                // Variables
                var counter = 0
                var isRunning = true

                print("App: \\(appName)")
                print("Pi value: \\(pi)")
                print("Counter: \\(counter)")
                print("Is running: \\(isRunning)")

                // Modify variables
                counter += 1
                isRunning = false

                print("Updated counter: \\(counter)")
                print("Updated isRunning: \\(isRunning)")
                """),
            ("Functions", """
                import Foundation

                func greet(name: String) -> String {
                    return "Hello, \\(name)!"
                }

                func add(_ a: Int, _ b: Int) -> Int {
                    return a + b
                }

                func factorial(_ n: Int) -> Int {
                    if n <= 1 {
                        return 1
                    }
                    return n * factorial(n - 1)
                }

                // Test the functions
                print(greet(name: "Swift Developer"))
                print("5 + 3 = \\(add(5, 3))")
                print("5! = \\(factorial(5))")
                """)
        ]
        
        for (name, content) in sampleCodes {
            if !codeFileExists(name: name) {
                try? saveCodeFile(name: name, content: content)
            }
        }
    }
}