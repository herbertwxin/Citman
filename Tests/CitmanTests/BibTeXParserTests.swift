import XCTest
@testable import Citman

final class BibTeXParserTests: XCTestCase {
    
    func testBasicParsing() {
        let bibtex = """
        @article{smith2023,
            title = {Swift Programming},
            author = {John Smith},
            year = {2023}
        }
        """
        
        let entries = BibTeXParser.parse(content: bibtex)
        XCTAssertEqual(entries.count, 1)
        
        let entry = entries.first!
        XCTAssertEqual(entry.id, "smith2023")
        XCTAssertEqual(entry.type, "article")
        XCTAssertEqual(entry.title, "Swift Programming")
        XCTAssertEqual(entry.author, "John Smith")
        XCTAssertEqual(entry.year, "2023")
    }
    
    func testMultipleEntries() {
        let bibtex = """
        @article{one, title={One}}
        @book{two, title={Two}}
        """
        
        let entries = BibTeXParser.parse(content: bibtex)
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].id, "one")
        XCTAssertEqual(entries[1].id, "two")
    }
    
    func testQuotedValues() {
        let bibtex = """
        @misc{quoted,
            title = "Quoted Title",
            author = "Jane Doe"
        }
        """
        
        let entries = BibTeXParser.parse(content: bibtex)
        XCTAssertEqual(entries.first?.title, "Quoted Title")
        XCTAssertEqual(entries.first?.author, "Jane Doe")
    }
    
    func testMixedDelimiters() {
        let bibtex = """
        @misc{mixed,
            title = {Braced Title},
            year = "2024",
            month = jan
        }
        """
        
        let entries = BibTeXParser.parse(content: bibtex)
        XCTAssertEqual(entries.first?.fields["title"], "Braced Title")
        XCTAssertEqual(entries.first?.fields["year"], "2024")
        // The current regex parser supports unquoted identifiers (like 1234), let's see if it catches 'jan'
        XCTAssertEqual(entries.first?.fields["month"], "jan")
    }
    
    func testCleanProperty() {
        // Test the 'clean' computed property logic in BibTeXEntry
        let fields = ["title": "{Protected} Title"]
        let entry = BibTeXEntry(id: "1", type: "misc", fields: fields)
        
        XCTAssertEqual(entry.title, "Protected Title")
    }
    
    func testSerialization() {
        let entry = BibTeXEntry(id: "test1", type: "article", fields: ["title": "Test Title", "year": "2023"])
        let output = BibTeXParser.serialize(entries: [entry])
        
        XCTAssertTrue(output.contains("@article{test1,"))
        XCTAssertTrue(output.contains("title = {Test Title}"))
        XCTAssertTrue(output.contains("year = {2023}"))
    }
    
    // This test checks for nested brace handling, which is common in BibTeX (e.g. to preserve capitalization)
    // The current regex might struggle here, which leads into "Option 4: Robust Parsing"
    func testNestedBraces() {
        let bibtex = """
        @article{nested,
            title = {The {C} Programming Language}
        }
        """
        
        let entries = BibTeXParser.parse(content: bibtex)
        // If the regex is simple, it might stop at the first closing brace `}`
        // expecting "The {C" instead of "The {C} Programming Language"
        XCTAssertEqual(entries.first?.fields["title"], "The {C} Programming Language")
    }
}
