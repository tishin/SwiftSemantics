@testable import SwiftSemantics
import SwiftParser
import XCTest

final class AssociatedTypeTests: XCTestCase {
    func testAssociatedTypeDeclaration() throws {
        let source = #"""
        associatedtype T
        """#

        let declarations = try SwiftParser.Parser.declarations(of: AssociatedType.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let associatedType = declarations.first!

        XCTAssertEqual(associatedType.attributes.count, 0)
        XCTAssertEqual(associatedType.name, "T")
        XCTAssertEqual(associatedType.description, "associatedtype T")
    }

    static var allTests = [
        ("testAssociatedTypeDeclaration", testAssociatedTypeDeclaration),
    ]
}

