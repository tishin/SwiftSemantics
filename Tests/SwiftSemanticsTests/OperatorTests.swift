@testable import SwiftSemantics
import SwiftParser
import XCTest

final class OperatorTests: XCTestCase {
    func testSimpleOperatorDeclaration() throws {
        let source = #"""
        prefix operator +++
        """#

        let declarations = try SwiftParser.Parser.declarations(of: Operator.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssertEqual(declaration.fixity, "prefix")
        XCTAssertEqual(declaration.kind, .prefix)
        XCTAssertEqual(declaration.name, "+++")
//        XCTAssertEqual(declaration.description, source)
    }

    static var allTests = [
        ("testSimpleOperatorDeclaration", testSimpleOperatorDeclaration),
    ]
}

