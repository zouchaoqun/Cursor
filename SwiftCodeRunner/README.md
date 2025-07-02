# Swift Code Runner - iOS App

A complete iOS application that allows users to write, store, and execute custom Swift code directly on their device.

## Features

### 📝 Code Writing & Editing
- **Full-featured code editor** with syntax highlighting
- **Monospace font** for better code readability
- **Auto-completion** and smart editing features
- **Comment/uncomment** functionality
- **Indent/unindent** selection tools
- **Real-time syntax highlighting** for Swift keywords, strings, comments, and numbers

### 💾 File Management
- **Documents-based storage** - All code files are saved in the user's Documents folder
- **Automatic file management** with creation, editing, and deletion capabilities
- **File browser** showing all saved Swift code files
- **Sample code files** automatically created on first launch
- **File preview** showing modification dates and code snippets

### ▶️ Code Execution
- **Built-in Swift interpreter** for executing code safely
- **Real-time output display** in a dedicated execution window
- **Error handling** with detailed error messages
- **Support for basic Swift operations**:
  - Variables and constants
  - Print statements
  - Basic functions (factorial, greet, add)
  - String interpolation
  - Simple arithmetic operations

### 🎨 User Interface
- **Modern iOS design** following Apple's Human Interface Guidelines
- **Dark/Light mode support** with system appearance
- **Navigation-based interface** for smooth user experience
- **Responsive layout** supporting both iPhone and iPad
- **Accessible design** with proper contrast and font sizing

## App Structure

### Main Components

1. **CodeListViewController** - Main screen showing all saved code files
   - File list with previews and modification dates
   - Create, edit, and delete operations
   - Quick action menu for each file

2. **CodeEditorViewController** - Full-featured code editor
   - Syntax highlighting for Swift code
   - Editing toolbar with common operations
   - Save and run functionality
   - Unsaved changes detection

3. **CodeExecutionViewController** - Code execution and output display
   - Shows the code being executed
   - Real-time output display
   - Error handling and formatting
   - Direct link back to editor

4. **CodeFileManager** - File operations manager
   - Handles all file I/O operations
   - Manages the Documents directory structure
   - Provides sample code generation

5. **SwiftCodeRunner** - Code execution engine
   - Safe Swift code interpretation
   - Variable and function management
   - Error handling and reporting

## Supported Swift Features

The app includes a simplified Swift interpreter that supports:

### Basic Operations
- Variable declarations (`let`, `var`)
- Print statements with string interpolation
- Comments (single-line with `//`)
- Basic arithmetic operations
- Boolean values

### Built-in Functions
- `print()` - Output text to console
- `greet(name:)` - Sample greeting function
- `add(_:_:)` - Addition function
- `factorial(_:)` - Recursive factorial calculation

### Data Types
- Integers and floating-point numbers
- Strings with interpolation
- Boolean values

## Installation & Setup

### Requirements
- iOS 16.0 or later
- Xcode 14.0 or later (for development)
- iPhone or iPad device

### Building the App
1. Open `SwiftCodeRunner.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

### First Launch
- The app automatically creates sample Swift files
- These demonstrate basic Swift syntax and features
- Users can immediately start experimenting with code

## Usage Guide

### Creating a New Code File
1. Tap the "+" button in the main screen
2. Enter a name for your Swift file
3. The editor opens with a basic template
4. Start writing your Swift code

### Editing Code
1. Select a file from the main list
2. Choose "Edit" from the action menu
3. Use the built-in editor with syntax highlighting
4. Save using the save button or auto-save on run

### Running Code
1. From the file list, select "Run" for any file
2. Or use the "Run" button in the editor
3. View output in the execution window
4. Debug any errors using the detailed error messages

### Managing Files
- **Delete**: Swipe left on any file in the list
- **Edit**: Tap a file and select "Edit"
- **Run**: Tap a file and select "Run"

## Sample Code Files

The app includes three sample files:

### Hello World
Basic Swift printing and variable usage

### Variables and Constants
Demonstrates Swift variable declarations and modifications

### Functions
Shows function definitions and usage including recursion

## Technical Architecture

### File Storage
- Uses iOS Documents directory for persistent storage
- Files are saved with `.swift` extension
- Automatic directory creation and management

### Code Execution
- Custom Swift interpreter built with `NSExpression` for safe evaluation
- Sandboxed execution environment
- No access to device APIs for security

### UI Components
- Built with UIKit for native iOS performance
- Auto Layout for responsive design
- Navigation Controller-based architecture

## Security & Limitations

### Security Features
- **Sandboxed execution** - Code runs in isolated environment
- **No system access** - Cannot access device functions or files
- **Safe evaluation** - Uses NSExpression for arithmetic operations

### Current Limitations
- **Simplified Swift support** - Not a full Swift compiler
- **No iOS frameworks** - Cannot import UIKit, Foundation beyond basic types
- **Basic function support** - Limited to predefined functions
- **No class/struct definitions** - Only basic language constructs

## Future Enhancements

### Planned Features
- Extended Swift language support
- Code sharing capabilities
- Syntax error highlighting
- Code completion suggestions
- Multiple file projects
- Import/export functionality

### Advanced Features
- Integration with Swift Package Manager
- Cloud synchronization
- Collaborative editing
- Educational content and tutorials

## Contributing

This is a demonstration project showcasing iOS development with Swift. The code is well-documented and follows iOS development best practices.

### Code Structure
- **MVVM-like architecture** with clear separation of concerns
- **Protocol-oriented programming** where applicable
- **Memory management** with weak references and proper cleanup
- **Error handling** with comprehensive error types

## License

This project is created for educational and demonstration purposes. Feel free to use and modify according to your needs.

---

**Swift Code Runner** - Bringing Swift programming to your iOS device! 🚀📱