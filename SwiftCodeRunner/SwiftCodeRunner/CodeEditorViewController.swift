import UIKit

class CodeEditorViewController: UIViewController {
    
    private let codeFile: CodeFile
    private let textView = UITextView()
    private let fileManager = CodeFileManager.shared
    
    init(codeFile: CodeFile) {
        self.codeFile = codeFile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }
    
    private func setupUI() {
        title = codeFile.name
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelEditing)
        )
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .save,
                target: self,
                action: #selector(saveCode)
            ),
            UIBarButtonItem(
                title: "Run",
                style: .plain,
                target: self,
                action: #selector(runCode)
            )
        ]
        
        // Text view setup
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.keyboardType = .asciiCapable
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add line numbers background
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 16)
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add toolbar for quick actions
        setupToolbar()
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let indentButton = UIBarButtonItem(title: "Indent", style: .plain, target: self, action: #selector(indentSelection))
        let unindentButton = UIBarButtonItem(title: "Unindent", style: .plain, target: self, action: #selector(unindentSelection))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let commentButton = UIBarButtonItem(title: "Comment", style: .plain, target: self, action: #selector(toggleComment))
        
        toolbar.items = [indentButton, unindentButton, flexSpace, commentButton]
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }
    
    private func loadContent() {
        textView.text = codeFile.content
        applySyntaxHighlighting()
    }
    
    private func applySyntaxHighlighting() {
        let text = textView.text ?? ""
        let attributedText = NSMutableAttributedString(string: text)
        
        // Reset attributes
        attributedText.addAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.label
        ], range: NSRange(location: 0, length: text.count))
        
        // Keywords
        let keywords = ["import", "func", "var", "let", "if", "else", "for", "while", "return", "class", "struct", "enum", "protocol", "extension", "public", "private", "internal", "static", "override", "init", "deinit", "true", "false", "nil"]
        
        for keyword in keywords {
            let regex = try! NSRegularExpression(pattern: "\\b\(keyword)\\b")
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
            for match in matches {
                attributedText.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: match.range)
            }
        }
        
        // Strings
        let stringRegex = try! NSRegularExpression(pattern: "\"[^\"]*\"")
        let stringMatches = stringRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
        for match in stringMatches {
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemRed, range: match.range)
        }
        
        // Comments
        let commentRegex = try! NSRegularExpression(pattern: "//.*$", options: .anchorsMatchLines)
        let commentMatches = commentRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
        for match in commentMatches {
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: match.range)
        }
        
        // Numbers
        let numberRegex = try! NSRegularExpression(pattern: "\\b\\d+(\\.\\d+)?\\b")
        let numberMatches = numberRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
        for match in numberMatches {
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: match.range)
        }
        
        textView.attributedText = attributedText
    }
    
    @objc private func cancelEditing() {
        if textView.text != codeFile.content {
            let alert = UIAlertController(
                title: "Unsaved Changes",
                message: "You have unsaved changes. Do you want to save before closing?",
                preferredStyle: .alert
            )
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                self?.saveCode()
                self?.dismiss(animated: true)
            }
            
            let discardAction = UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(saveAction)
            alert.addAction(discardAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func saveCode() {
        do {
            try fileManager.saveCodeFile(name: codeFile.name, content: textView.text)
            showAlert(title: "Saved", message: "File saved successfully!")
        } catch {
            showAlert(title: "Error", message: "Failed to save file: \(error.localizedDescription)")
        }
    }
    
    @objc private func runCode() {
        // Save first
        do {
            try fileManager.saveCodeFile(name: codeFile.name, content: textView.text)
        } catch {
            showAlert(title: "Error", message: "Failed to save file: \(error.localizedDescription)")
            return
        }
        
        // Create updated code file
        let updatedCodeFile = CodeFile(
            name: codeFile.name,
            content: textView.text,
            dateCreated: codeFile.dateCreated,
            dateModified: Date()
        )
        
        let executionVC = CodeExecutionViewController(codeFile: updatedCodeFile)
        let navController = UINavigationController(rootViewController: executionVC)
        present(navController, animated: true)
    }
    
    @objc private func indentSelection() {
        guard let selectedRange = textView.selectedTextRange else { return }
        
        let selectedText = textView.text(in: selectedRange) ?? ""
        let indentedText = selectedText.components(separatedBy: .newlines).map { "    " + $0 }.joined(separator: "\n")
        
        textView.replace(selectedRange, withText: indentedText)
        applySyntaxHighlighting()
    }
    
    @objc private func unindentSelection() {
        guard let selectedRange = textView.selectedTextRange else { return }
        
        let selectedText = textView.text(in: selectedRange) ?? ""
        let unindentedText = selectedText.components(separatedBy: .newlines).map { line in
            if line.hasPrefix("    ") {
                return String(line.dropFirst(4))
            } else if line.hasPrefix("\t") {
                return String(line.dropFirst())
            }
            return line
        }.joined(separator: "\n")
        
        textView.replace(selectedRange, withText: unindentedText)
        applySyntaxHighlighting()
    }
    
    @objc private func toggleComment() {
        guard let selectedRange = textView.selectedTextRange else { return }
        
        let selectedText = textView.text(in: selectedRange) ?? ""
        let lines = selectedText.components(separatedBy: .newlines)
        
        // Check if all lines are commented
        let allCommented = lines.allSatisfy { $0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
        
        let modifiedText: String
        if allCommented {
            // Uncomment
            modifiedText = lines.map { line in
                if let range = line.range(of: "//") {
                    var result = line
                    result.removeSubrange(range.lowerBound..<line.index(range.lowerBound, offsetBy: 2))
                    if result.hasPrefix(" ") {
                        result.removeFirst()
                    }
                    return result
                }
                return line
            }.joined(separator: "\n")
        } else {
            // Comment
            modifiedText = lines.map { "// " + $0 }.joined(separator: "\n")
        }
        
        textView.replace(selectedRange, withText: modifiedText)
        applySyntaxHighlighting()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension CodeEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Apply syntax highlighting with a small delay to avoid performance issues
        NSObject.cancelPreviousPerformRequests(target: self, selector: #selector(applySyntaxHighlightingDelayed), object: nil)
        perform(#selector(applySyntaxHighlightingDelayed), with: nil, afterDelay: 0.1)
    }
    
    @objc private func applySyntaxHighlightingDelayed() {
        applySyntaxHighlighting()
    }
}