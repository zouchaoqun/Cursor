import UIKit

class CodeExecutionViewController: UIViewController {
    
    private let codeFile: CodeFile
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let codeLabel = UILabel()
    private let outputTextView = UITextView()
    private let runButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let codeRunner = SwiftCodeRunner.shared
    
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
        displayCode()
    }
    
    private func setupUI() {
        title = "Running: \(codeFile.name)"
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissViewController)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editCode)
        )
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Code display label
        codeLabel.numberOfLines = 0
        codeLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        codeLabel.backgroundColor = .secondarySystemBackground
        codeLabel.textColor = .label
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.layer.cornerRadius = 8
        codeLabel.layer.masksToBounds = true
        
        // Add padding to code label
        let codeLabelContainer = UIView()
        codeLabelContainer.backgroundColor = .secondarySystemBackground
        codeLabelContainer.layer.cornerRadius = 8
        codeLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        codeLabelContainer.addSubview(codeLabel)
        
        // Run button
        runButton.setTitle("▶ Run Code", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        runButton.layer.cornerRadius = 8
        runButton.translatesAutoresizingMaskIntoConstraints = false
        runButton.addTarget(self, action: #selector(runCode), for: .touchUpInside)
        
        // Activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        // Output section
        let outputHeader = UILabel()
        outputHeader.text = "Output:"
        outputHeader.font = .boldSystemFont(ofSize: 16)
        outputHeader.textColor = .label
        outputHeader.translatesAutoresizingMaskIntoConstraints = false
        
        outputTextView.isEditable = false
        outputTextView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        outputTextView.backgroundColor = .tertiarySystemBackground
        outputTextView.textColor = .label
        outputTextView.layer.cornerRadius = 8
        outputTextView.layer.borderWidth = 1
        outputTextView.layer.borderColor = UIColor.separator.cgColor
        outputTextView.translatesAutoresizingMaskIntoConstraints = false
        outputTextView.text = "Tap 'Run Code' to execute"
        outputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Add all views to content view
        contentView.addSubview(codeLabelContainer)
        contentView.addSubview(runButton)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(outputHeader)
        contentView.addSubview(outputTextView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Code label container
            codeLabelContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            codeLabelContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            codeLabelContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Code label inside container
            codeLabel.topAnchor.constraint(equalTo: codeLabelContainer.topAnchor, constant: 12),
            codeLabel.leadingAnchor.constraint(equalTo: codeLabelContainer.leadingAnchor, constant: 12),
            codeLabel.trailingAnchor.constraint(equalTo: codeLabelContainer.trailingAnchor, constant: -12),
            codeLabel.bottomAnchor.constraint(equalTo: codeLabelContainer.bottomAnchor, constant: -12),
            
            // Run button
            runButton.topAnchor.constraint(equalTo: codeLabelContainer.bottomAnchor, constant: 16),
            runButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            runButton.widthAnchor.constraint(equalToConstant: 200),
            runButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: runButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: runButton.centerYAnchor),
            
            // Output header
            outputHeader.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 24),
            outputHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            outputHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Output text view
            outputTextView.topAnchor.constraint(equalTo: outputHeader.bottomAnchor, constant: 8),
            outputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            outputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            outputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            outputTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func displayCode() {
        // Apply syntax highlighting to the code display
        let attributedCode = applySyntaxHighlighting(to: codeFile.content)
        codeLabel.attributedText = attributedCode
    }
    
    private func applySyntaxHighlighting(to text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        
        // Reset attributes
        attributedText.addAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
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
        
        return attributedText
    }
    
    @objc private func runCode() {
        runButton.isHidden = true
        activityIndicator.startAnimating()
        outputTextView.text = "Executing code..."
        
        codeRunner.executeCode(codeFile.content) { [weak self] result in
            DispatchQueue.main.async {
                self?.runButton.isHidden = false
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let output):
                    self?.outputTextView.text = output
                    self?.outputTextView.textColor = .label
                case .failure(let error):
                    self?.outputTextView.text = "Error: \(self?.formatError(error) ?? "Unknown error")"
                    self?.outputTextView.textColor = .systemRed
                }
            }
        }
    }
    
    private func formatError(_ error: SwiftCodeRunner.RunnerError) -> String {
        switch error {
        case .compilationError(let message):
            return "Compilation Error: \(message)"
        case .runtimeError(let message):
            return "Runtime Error: \(message)"
        case .unsupportedOperation(let message):
            return "Unsupported Operation: \(message)"
        }
    }
    
    @objc private func editCode() {
        let editorVC = CodeEditorViewController(codeFile: codeFile)
        let navController = UINavigationController(rootViewController: editorVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
}