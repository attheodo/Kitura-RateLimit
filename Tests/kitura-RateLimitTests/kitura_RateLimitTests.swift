import XCTest
@testable import kitura_RateLimit

class kitura_RateLimitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(kitura_RateLimit().text, "Hello, World!")
    }


    static var allTests : [(String, (kitura_RateLimitTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
