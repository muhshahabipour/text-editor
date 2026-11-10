import XCTest
@testable import EditorCore

final class PersianTextTests: XCTestCase {
    func testNormalizeArabicYehAndKaf() {
        XCTAssertEqual(PersianText.normalizeLetters("كتاب علي"), "کتاب علی")
    }
    func testNormalizeLeavesPersianAlone() {
        XCTAssertEqual(PersianText.normalizeLetters("کتاب"), "کتاب")
    }
    func testToPersianDigits() {
        XCTAssertEqual(PersianText.toPersianDigits("Line 12: 3,400"), "Line ۱۲: ۳,۴۰۰")
    }
    func testFindIgnoringVariants() {
        let text = "او كتاب خواند"      // Arabic kaf
        let r = PersianText.findRanges(of: "کتاب", in: text, ignoreVariants: true)
        XCTAssertEqual(r, [NSRange(location: 3, length: 4)])
    }
    func testFindStrictDoesNotIgnoreVariants() {
        let r = PersianText.findRanges(of: "کتاب", in: "او كتاب خواند", ignoreVariants: false)
        XCTAssertTrue(r.isEmpty)
    }
    func testFindMultipleAndCaseInsensitiveLatin() {
        let r = PersianText.findRanges(of: "ab", in: "AB ab xab", ignoreVariants: true)
        XCTAssertEqual(r.count, 3)
    }
    func testFindEmptyQuery() {
        XCTAssertTrue(PersianText.findRanges(of: "", in: "abc", ignoreVariants: true).isEmpty)
    }
}
