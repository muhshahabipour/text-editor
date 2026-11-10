import XCTest
@testable import EditorCore

final class StatsCalculatorTests: XCTestCase {
    func testPersianWords() {
        XCTAssertEqual(StatsCalculator.stats(for: "سلام دنیا"),
                       TextStats(words: 2, characters: 9, lines: 1))
    }
    func testZWNJKeepsWordTogether() {
        XCTAssertEqual(StatsCalculator.stats(for: "می‌خواهم hello").words, 2)
    }
    func testLinesCountTrailingNewline() {
        XCTAssertEqual(StatsCalculator.stats(for: "a\nb\n"),
                       TextStats(words: 2, characters: 4, lines: 3))
    }
    func testEmpty() {
        XCTAssertEqual(StatsCalculator.stats(for: ""),
                       TextStats(words: 0, characters: 0, lines: 1))
    }
    func testEmojiIsOneCharacter() {
        XCTAssertEqual(StatsCalculator.stats(for: "👨‍👩‍👧").characters, 1)
    }
    func testPositionFirstLine() {
        let p = StatsCalculator.position(in: "abc", utf16Offset: 2)
        XCTAssertEqual(p.line, 1); XCTAssertEqual(p.column, 3)
    }
    func testPositionSecondLine() {
        let p = StatsCalculator.position(in: "abc\nسلام", utf16Offset: 6)
        XCTAssertEqual(p.line, 2); XCTAssertEqual(p.column, 3)
    }
    func testPositionClampsOffset() {
        let p = StatsCalculator.position(in: "ab", utf16Offset: 99)
        XCTAssertEqual(p.line, 1); XCTAssertEqual(p.column, 3)
    }
}
