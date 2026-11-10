import XCTest
@testable import EditorCore
final class SmokeTests: XCTestCase {
    func testVersion() { XCTAssertEqual(EditorCore.version, "1") }
}
