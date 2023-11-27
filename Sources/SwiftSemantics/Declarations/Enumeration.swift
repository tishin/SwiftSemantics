import SwiftSyntax

/// An enumeration declaration.
public struct Enumeration: Declaration, Hashable, Codable {
    /// The enumeration declaration attributes.
    public let attributes: [Attribute]

    /// The enumeration declaration modifiers.
    public let modifiers: [Modifier]

    /// The enumeration declaration keyword (`enum`).
    public let keyword: String

    /// The name of the enumeration.
    public let name: String

    /**
     A list of inherited type names.

     If the enumeration is raw representable,
     the first element is the raw value type.
     Any other elements are names of protocols.

     For example,
     given the following declarations,
     the `inheritance` of enumeration `E` is `["Int", "P"]`:

     ```swift
     protocol P {}
     enum E: Int, P {}
     ```
     */
    public let inheritance: [String]

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of enumeration `E`
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Equatable"`:

     ```swift
     enum E<T: Equatable> {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of enumeration `E`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hashable"`:

     ```swift
     enum E<T> where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// An enumeration case.
    public struct Case: Declaration, Hashable, Codable {
        /// The declaration attributes.
        public let attributes: [Attribute]

        /// The declaration modifiers.
        public let modifiers: [Modifier]

        /// The declaration keyword (`"case"`).
        public let keyword: String

        /// The enumeration case name.
        public let name: String

        /// The associated values of the enumeration case, if any.
        public let associatedValue: [Enumeration.Parameter]?

        /// The raw value of the enumeration case, if any.
        public let rawValue: String?
    }
    
    /**
     A function parameter.

     This type can also be used to represent
     initializer parameters and associated values for enumeration cases.
     */
    public struct Parameter: Hashable, Codable {
        
        /**
         The first, external name of the parameter.
         
         For example,
         given the following function declaration,
         the first parameter has a `firstName` equal to `nil`,
         and the second parameter has a `firstName` equal to `"by"`:
         
         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let firstName: String?
        
        /**
         The second, internal name of the parameter.
         
         For example,
         given the following function declaration,
         the first parameter has a `secondName` equal to `"number"`,
         and the second parameter has a `secondName` equal to `"amount"`:
         
         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let secondName: String?
        
        /**
         The type identified by the parameter.
         
         For example,
         given the following function declaration,
         the first parameter has a `type` equal to `"Person"`,
         and the second parameter has a `type` equal to `"String"`:
         
         ```swift
         func greet(_ person: Person, with phrases: String...)
         ```
         */
        public let type: String?
        
        /**
         The default argument of the parameter.
         
         For example,
         given the following function declaration,
         the second parameter has a default argument equal to `"1"`.
         
         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let defaultArgument: String?
    }
}

// MARK: - CustomStringConvertible

extension Enumeration: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

extension Enumeration.Case: CustomStringConvertible {
    public var description: String {
        if let associatedValue = associatedValue {
            return "\(keyword) \(name)(\(associatedValue.map{"\($0)"}.joined(separator: ", ")))"
        } else {
            return "\(keyword) \(name)"
        }
    }
}

// MARK: - ExpressibleBySyntax

extension Enumeration: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: EnumDeclSyntax) {
        attributes = node.attributes.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) }
        modifiers = node.modifiers.map { Modifier($0) }
        keyword = node.enumKeyword.text.trimmed
        name = node.name.text.trimmed
        inheritance = node.inheritanceClause?.inheritedTypes.map { $0.type.description.trimmed } ?? []
        genericParameters = node.genericParameterClause?.parameters.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirements)
    }
}

extension Enumeration.Case {
    /// Creates and returns enumeration cases from an enumeration case declaration.
    public static func cases(from node: EnumCaseDeclSyntax) -> [Enumeration.Case] {
        return node.elements.compactMap { Enumeration.Case($0) }
    }

    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: EnumCaseElementSyntax) {
        guard let parent = node.context as? EnumCaseDeclSyntax else {
            assertionFailure("EnumCaseElement should be contained within EnumCaseDecl")
            return nil
        }

        attributes = parent.attributes.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) }
        modifiers = parent.modifiers.map { Modifier($0) }
        keyword = parent.caseKeyword.text.trimmed

        name = node.name.text.trimmed
        associatedValue = node.parameterClause?.parameters.map { Enumeration.Parameter($0) }
        rawValue = node.rawValue?.value.description.trimmed
    }
}

extension Enumeration.Parameter: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: EnumCaseParameterSyntax) {
        firstName = node.firstName?.text.trimmed
        secondName = node.secondName?.text.trimmed
        type = node.type.description.trimmed
        defaultArgument = node.defaultValue?.value.description.trimmed
    }
}
