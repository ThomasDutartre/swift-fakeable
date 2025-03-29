import SwiftSyntax
import SwiftSyntaxMacros
import FakeableParameters

public struct FakeableMacro: MemberMacro {
    /// Expands the macro by injecting a fake method into structs, classes, or enums.
    /// - Parameters:
    ///   - node: The attribute syntax of the macro.
    ///   - declaration: The declaration that the macro is applied to.
    ///   - context: The macro expansion context.
    /// - Throws: `MacroError.notSupported` if the declaration type is not supported.
    /// - Returns: An array of `DeclSyntax` containing the injected fake method.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let macroParameters = extractMacroParameters(from: node)

        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return injectFakeMethod(
                structName: structDecl.name.text,
                properties: extractProperties(from: structDecl.memberBlock.members),
                macroParameters: macroParameters
            )
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return injectFakeMethod(
                structName: classDecl.name.text,
                properties: extractProperties(from: classDecl.memberBlock.members),
                macroParameters: macroParameters
            )
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return injectFakeMethod(enumDecl, macroParameters: macroParameters)
        } else {
            throw MacroError.notSupported
        }
    }

    /// Extracts macro parameters from an attribute syntax node.
    /// - Parameter node: The attribute syntax node.
    /// - Returns: A `FakeableParameters` object populated with extracted values.
    static func extractMacroParameters(from node: AttributeSyntax) -> FakeableParameters {
        var macroParameters = FakeableParameters()

        // Check if the arguments exist in the node
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return macroParameters // If no arguments are found, return the default empty parameters
        }

        // Iterate through each argument in the node
        arguments.forEach { argument in
            // Ensure the label (name) is not nil and can be used
            guard let label = argument.label?.text else {
                return // Skip arguments with missing labels
            }

            let valueExpression: ExprSyntax = argument.expression

            // Handle specific labels and extract corresponding values
            if label == "collectionCount" {
                if let integerLiteral = valueExpression.as(IntegerLiteralExprSyntax.self),
                   let intValue = Int(integerLiteral.literal.text) {
                    macroParameters.collectionCount = intValue
                }
            } else if label == "behindPreprocessorFlag" {
                if let stringLiteral = valueExpression.as(StringLiteralExprSyntax.self) {
                    macroParameters.behindPreprocessorFlag = stringLiteral.segments.first?.description
                }
            }
        }

        return macroParameters
    }

    /// Returns a default value for a given type.
    /// - Parameters:
    ///   - rawType: The raw type string.
    ///   - macroParameters: Additional parameters controlling macro behavior.
    /// - Returns: A string representing the default value.
    static func parameterDefaultValue(for rawType: String, macroParameters: FakeableParameters) -> String {
        let type: String = rawType.isOptional ? String(rawType.dropLast()) : rawType

        if type.isTuple {
            let elements = type.tupleElements
                .map { parameterDefaultValue(for: $0, macroParameters: macroParameters) }
            return "(\(elements.joined(separator: ", ")))"
        }

        if type.isDictionary {
            let (keyType, valueType) = type.dictionaryKeyValue

            let pairs = (0..<macroParameters.collectionCount)
                .map { _ in
                    let key = Randomiser.randomValue(for: keyType)
                    let value = parameterDefaultValue(for: valueType, macroParameters: macroParameters)
                    return "\(key): \(value)"
                }
                .joined(separator: ", ")

            return "[\(pairs)]"
        }

        if type.isCollection {
            let elementType = type.collectionType

            let elements = (0..<macroParameters.collectionCount)
                .map { _ in parameterDefaultValue(for: elementType, macroParameters: macroParameters) }
                .joined(separator: ", ")

            if type.isArray {
                return "[\(elements)]"
            }
            if type.isSet {
                return "Set(arrayLiteral: \(elements))"
            }
        }

        return Randomiser.randomValue(for: type)
    }
}
