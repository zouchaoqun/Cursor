import UIKit

class CodeListViewController: UIViewController {
    
    private let tableView = UITableView()
    private var codeFiles: [CodeFile] = []
    private let fileManager = CodeFileManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCodeFiles()
        
        // Create sample files on first launch
        fileManager.createSampleFiles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCodeFiles()
    }
    
    private func setupUI() {
        title = "Swift Code Runner"
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCodeFile)
        )
        
        // Table view setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CodeFileTableViewCell.self, forCellReuseIdentifier: "CodeFileCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadCodeFiles() {
        codeFiles = fileManager.loadCodeFiles()
        tableView.reloadData()
    }
    
    @objc private func addCodeFile() {
        let alert = UIAlertController(title: "New Swift File", message: "Enter a name for your Swift file", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "File name"
            textField.autocapitalizationType = .words
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let fileName = alert.textFields?.first?.text, !fileName.isEmpty else { return }
            self?.createNewCodeFile(name: fileName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createNewCodeFile(name: String) {
        let defaultContent = """
        import Foundation

        // Your Swift code here
        print("Hello from \\(name)!")
        """
        
        do {
            try fileManager.saveCodeFile(name: name, content: defaultContent)
            loadCodeFiles()
            
            // Open the new file for editing
            if let newFile = codeFiles.first(where: { $0.name == name }) {
                openCodeEditor(for: newFile)
            }
        } catch {
            showAlert(title: "Error", message: "Failed to create file: \(error.localizedDescription)")
        }
    }
    
    private func openCodeEditor(for codeFile: CodeFile) {
        let editorVC = CodeEditorViewController(codeFile: codeFile)
        let navController = UINavigationController(rootViewController: editorVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func runCode(for codeFile: CodeFile) {
        let executionVC = CodeExecutionViewController(codeFile: codeFile)
        let navController = UINavigationController(rootViewController: executionVC)
        present(navController, animated: true)
    }
    
    private func deleteCodeFile(at indexPath: IndexPath) {
        let codeFile = codeFiles[indexPath.row]
        
        let alert = UIAlertController(
            title: "Delete File",
            message: "Are you sure you want to delete '\(codeFile.name)'?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            do {
                try self?.fileManager.deleteCodeFile(name: codeFile.name)
                self?.loadCodeFiles()
            } catch {
                self?.showAlert(title: "Error", message: "Failed to delete file: \(error.localizedDescription)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CodeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codeFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CodeFileCell", for: indexPath) as! CodeFileTableViewCell
        cell.configure(with: codeFiles[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CodeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let codeFile = codeFiles[indexPath.row]
        
        let alert = UIAlertController(title: codeFile.name, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.openCodeEditor(for: codeFile)
        }
        
        let runAction = UIAlertAction(title: "Run", style: .default) { [weak self] _ in
            self?.runCode(for: codeFile)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(runAction)
        alert.addAction(cancelAction)
        
        // Configure for iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: indexPath)
        }
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCodeFile(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Custom Table View Cell
class CodeFileTableViewCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let previewLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textColor = .label
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = .tertiaryLabel
        previewLabel.numberOfLines = 2
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, dateLabel, previewLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with codeFile: CodeFile) {
        nameLabel.text = codeFile.name
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = "Modified: \(formatter.string(from: codeFile.dateModified))"
        
        // Show first non-empty line as preview
        let lines = codeFile.content.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !$0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("//") && !$0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("import") }
        previewLabel.text = nonEmptyLines.first ?? "Empty file"
    }
}