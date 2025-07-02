import Foundation

class SwiftCodeRunner {
    static let shared = SwiftCodeRunner()
    
    private init() {}
    
    enum RunnerError: Error {
        case compilationError(String)
        case runtimeError(String)
        case unsupportedOperation(String)
    }
    
    func executeCode(_ code: String, completion: @escaping (Result<String, RunnerError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let output = try self.runSwiftCode(code)
                DispatchQueue.main.async {
                    completion(.success(output))
                }
            } catch let error as RunnerError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.runtimeError(error.localizedDescription)))
                }
            }
        }
    }
    
    private func runSwiftCode(_ code: String) throws -> String {
        var output = ""
        
        // Simple Swift code interpreter
        // This is a simplified version that can handle basic Swift operations
        let lines = code.components(separatedBy: .newlines)
        var variables: [String: Any] = [:]
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") || trimmedLine.hasPrefix("import") {
                continue
            }
            
            do {
                let result = try processLine(trimmedLine, variables: &variables)
                if !result.isEmpty {
                    output += result + "\n"
                }
            } catch {
                throw RunnerError.runtimeError("Error in line '\(trimmedLine)': \(error.localizedDescription)")
            }
        }
        
        return output.isEmpty ? "Code executed successfully (no output)" : output
    }
    
    private func processLine(_ line: String, variables: inout [String: Any]) throws -> String {
        var output = ""
        
        // Handle print statements
        if line.contains("print(") {
            output += try handlePrintStatement(line, variables: variables)
        }
        // Handle variable declarations
        else if line.contains("let ") || line.contains("var ") {
            try handleVariableDeclaration(line, variables: &variables)
        }
        // Handle variable assignments
        else if line.contains("=") && !line.contains("==") && !line.contains("!=") && !line.contains("<=") && !line.contains(">=") {
            try handleVariableAssignment(line, variables: &variables)
        }
        // Handle function calls (basic)
        else if line.contains("(") && line.contains(")") {
            output += try handleFunctionCall(line, variables: variables)
        }
        
        return output
    }
    
    private func handlePrintStatement(_ line: String, variables: [String: Any]) throws -> String {
        // Extract content between print( and )
        guard let startIndex = line.range(of: "print(")?.upperBound,
              let endIndex = line.lastIndex(of: ")") else {
            throw RunnerError.compilationError("Invalid print statement")
        }
        
        let content = String(line[startIndex..<endIndex])
        let evaluatedContent = try evaluateExpression(content, variables: variables)
        return String(describing: evaluatedContent)
    }
    
    private func handleVariableDeclaration(_ line: String, variables: inout [String: Any]) throws {
        let components = line.components(separatedBy: "=")
        guard components.count == 2 else {
            throw RunnerError.compilationError("Invalid variable declaration")
        }
        
        let leftSide = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let rightSide = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract variable name
        let varName: String
        if leftSide.hasPrefix("let ") {
            varName = String(leftSide.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if leftSide.hasPrefix("var ") {
            varName = String(leftSide.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw RunnerError.compilationError("Invalid variable declaration")
        }
        
        // Evaluate right side
        let value = try evaluateExpression(rightSide, variables: variables)
        variables[varName] = value
    }
    
    private func handleVariableAssignment(_ line: String, variables: inout [String: Any]) throws {
        let components = line.components(separatedBy: "=")
        guard components.count == 2 else {
            throw RunnerError.compilationError("Invalid assignment")
        }
        
        let varName = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let rightSide = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let value = try evaluateExpression(rightSide, variables: variables)
        variables[varName] = value
    }
    
    private func handleFunctionCall(_ line: String, variables: [String: Any]) throws -> String {
        // Handle simple built-in functions
        if line.contains("factorial(") {
            return try handleFactorialFunction(line, variables: variables)
        } else if line.contains("greet(") {
            return try handleGreetFunction(line, variables: variables)
        } else if line.contains("add(") {
            return try handleAddFunction(line, variables: variables)
        }
        
        return ""
    }
    
    private func handleFactorialFunction(_ line: String, variables: [String: Any]) throws -> String {
        guard let startIndex = line.range(of: "factorial(")?.upperBound,
              let endIndex = line.lastIndex(of: ")") else {
            throw RunnerError.compilationError("Invalid factorial function call")
        }
        
        let parameter = String(line[startIndex..<endIndex])
        let value = try evaluateExpression(parameter, variables: variables)
        
        guard let number = value as? Int else {
            throw RunnerError.runtimeError("Factorial requires an integer parameter")
        }
        
        let result = factorial(number)
        return String(result)
    }
    
    private func handleGreetFunction(_ line: String, variables: [String: Any]) throws -> String {
        guard let startIndex = line.range(of: "greet(name:")?.upperBound ?? line.range(of: "greet(")?.upperBound,
              let endIndex = line.lastIndex(of: ")") else {
            throw RunnerError.compilationError("Invalid greet function call")
        }
        
        let parameter = String(line[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        let value = try evaluateExpression(parameter, variables: variables)
        
        guard let name = value as? String else {
            throw RunnerError.runtimeError("Greet requires a string parameter")
        }
        
        return "Hello, \(name)!"
    }
    
    private func handleAddFunction(_ line: String, variables: [String: Any]) throws -> String {
        guard let startIndex = line.range(of: "add(")?.upperBound,
              let endIndex = line.lastIndex(of: ")") else {
            throw RunnerError.compilationError("Invalid add function call")
        }
        
        let parameters = String(line[startIndex..<endIndex])
        let paramArray = parameters.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        guard paramArray.count == 2 else {
            throw RunnerError.compilationError("Add function requires exactly 2 parameters")
        }
        
        let value1 = try evaluateExpression(paramArray[0], variables: variables)
        let value2 = try evaluateExpression(paramArray[1], variables: variables)
        
        guard let num1 = value1 as? Int, let num2 = value2 as? Int else {
            throw RunnerError.runtimeError("Add function requires integer parameters")
        }
        
        return String(num1 + num2)
    }
    
    private func factorial(_ n: Int) -> Int {
        if n <= 1 { return 1 }
        return n * factorial(n - 1)
    }
    
    private func evaluateExpression(_ expression: String, variables: [String: Any]) throws -> Any {
        let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle string literals
        if trimmed.hasPrefix("\"") && trimmed.hasSuffix("\"") {
            let content = String(trimmed.dropFirst().dropLast())
            return processStringInterpolation(content, variables: variables)
        }
        
        // Handle boolean literals
        if trimmed == "true" { return true }
        if trimmed == "false" { return false }
        
        // Handle numeric literals
        if let intValue = Int(trimmed) {
            return intValue
        }
        if let doubleValue = Double(trimmed) {
            return doubleValue
        }
        
        // Handle variables
        if let value = variables[trimmed] {
            return value
        }
        
        // Handle simple arithmetic expressions
        if trimmed.contains("+") || trimmed.contains("-") || trimmed.contains("*") || trimmed.contains("/") {
            return try evaluateArithmeticExpression(trimmed, variables: variables)
        }
        
        throw RunnerError.runtimeError("Unknown expression: \(trimmed)")
    }
    
    private func processStringInterpolation(_ string: String, variables: [String: Any]) -> String {
        var result = string
        
        // Simple string interpolation handling
        let regex = try! NSRegularExpression(pattern: "\\\\\\(([^)]+)\\)")
        let matches = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        
        for match in matches.reversed() {
            let range = Range(match.range(at: 1), in: string)!
            let variableName = String(string[range])
            
            if let value = variables[variableName] {
                let replacement = String(describing: value)
                let fullRange = Range(match.range, in: string)!
                result.replaceSubrange(fullRange, with: replacement)
            }
        }
        
        return result
    }
    
    private func evaluateArithmeticExpression(_ expression: String, variables: [String: Any]) throws -> Any {
        // Simple arithmetic evaluation
        var expr = expression.replacingOccurrences(of: " ", with: "")
        
        // Replace variables with their values
        for (name, value) in variables {
            if let numValue = value as? NSNumber {
                expr = expr.replacingOccurrences(of: name, with: numValue.stringValue)
            }
        }
        
        // Use NSExpression for safe evaluation of arithmetic
        let nsExpression = NSExpression(format: expr)
        if let result = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber {
            return result.intValue
        }
        
        throw RunnerError.runtimeError("Cannot evaluate arithmetic expression: \(expression)")
    }
}