import XCTest
@testable import EditorCore

final class TextEncodingDetectorTests: XCTestCase {
    func testUTF8() {
        let d = "سلام hello".data(using: .utf8)!
        let r = TextEncodingDetector.decode(d)
        XCTAssertEqual(r?.text, "سلام hello")
        XCTAssertEqual(r?.encoding, .utf8)
    }
    func testUTF8BOMStripped() {
        let d = Data([0xEF, 0xBB, 0xBF]) + "ab".data(using: .utf8)!
        XCTAssertEqual(TextEncodingDetector.decode(d)?.text, "ab")
    }
    func testUTF16LEWithBOM() {
        let d = "سلام".data(using: .utf16LittleEndian)!
        let withBOM = Data([0xFF, 0xFE]) + d
        let r = TextEncodingDetector.decode(withBOM)
        XCTAssertEqual(r?.text, "سلام")
        XCTAssertEqual(r?.encoding, .utf16)
    }
    func testWindows1256Fallback() {
        let d = Data([0xC8, 0xE1, 0xE5])   // "بله" in Windows-1256, invalid UTF-8
        let r = TextEncodingDetector.decode(d)
        XCTAssertEqual(r?.text, "بله")
        XCTAssertEqual(r?.encoding, TextEncodingDetector.windows1256)
    }
    func testExplicitEncoding() {
        let d = Data([0xC8, 0xE1, 0xE5])
        XCTAssertEqual(TextEncodingDetector.decode(d, using: TextEncodingDetector.windows1256), "بله")
        XCTAssertNil(TextEncodingDetector.decode(d, using: .utf8))
    }
    func testEmptyData() {
        XCTAssertEqual(TextEncodingDetector.decode(Data())?.text, "")
    }
}
