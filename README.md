# Citman

**Citman** is a native macOS citation manager designed for speed, style, and simplicity. It allows you to manage your BibTeX libraries with a clean, modern interface that feels right at home on your Mac.

## Features

*   **Native macOS Interface:** Built with SwiftUI for a smooth, responsive, and familiar user experience.
*   **BibTeX Support:** Open, edit, and save `.bib` files directly.
*   **Robust Parsing:** Handles complex BibTeX entries, including nested braces (e.g., `{The {C} Programming Language}`) and various field formats.
*   **Smart Search:** Instantly filter your library by ID, title, author, year, or any field content.
*   **Library Organization:** Automatically categorizes entries by type (Article, Book, Thesis, etc.) in the sidebar.
*   **Editing:** Add new citations or edit existing ones with ease.
*   **Sorting:** Sort your library by any column.

## Installation

### Via Homebrew (Recommended)

You can easily install Citman using [Homebrew](https://brew.sh/):

```bash
brew tap herbertwxin/citman
brew install citman
```

### From Source

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/citman.git
    cd citman
    ```

2.  **Build the application:**
    ```bash
    swift build -c release
    ```

3.  **Run:**
    The executable can be found in the build directory, or run directly via:
    ```bash
    swift run -c release
    ```
    *Note: To run as a standalone app, you can package the executable or run it from Xcode.*

### Opening the Project in Xcode

To contribute or develop, opening the package in Xcode is recommended:

1.  Double-click `Package.swift` or run `xed .` in the terminal.
2.  Select the `Citman` scheme and press `Cmd + R` to run.

## Usage

1.  **Open Library:** Launch Citman and open any `.bib` file.
2.  **Browse:** Use the sidebar to filter by entry type (e.g., "Article", "Book").
3.  **Search:** Use the search bar in the toolbar to find specific papers.
4.  **Edit:** Select a citation to view details in the inspector, or use the "Add" button (+) to create a new entry.
5.  **Export:** Changes are saved back to your `.bib` file efficiently.

## Development

### Running Tests

This project includes a test suite to ensure the BibTeX parser works correctly.

```bash
swift test
```

### Architecture

*   **SwiftUI:** For the user interface.
*   **BibTeXParser:** A custom, robust parser in `Sources/Citman/Models/BibTeXParser.swift` that handles nested structures using a character scanner.
*   **CI/CD:** GitHub Actions workflow configured in `.github/workflows/swift.yml`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.