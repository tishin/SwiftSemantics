@testable import SwiftSemantics
import SwiftParser
import XCTest

final class ProtocolTests: XCTestCase {
    func testProtocolDeclaration() throws {
        let source = #"""
        public protocol P {}
        """#

        let declarations = try SwiftParser.Parser.declarations(of: Protocol.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.name, "P")
    }

    static var allTests = [
        ("testProtocolDeclaration", testProtocolDeclaration),
    ]
}

