import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import FakeableParameters

struct FakeableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FakeableMacro.self
    ]
}

public struct FakeableMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let macroParameters: FakeableParameters = extractMacroParameters(from: node)

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
    
    private static func extractProperties(from itemList: MemberBlockItemListSyntax) -> [(String, String)] {
        itemList
            .compactMap { member in
                if let property = member.decl.as(VariableDeclSyntax.self),
                   let identifier = property.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                   let type = property.bindings.first?.typeAnnotation?.type.description {
                    return (identifier, type)
                } else {
                    return nil
                }
            }
    }
    
    static func extractMacroParameters(from node: AttributeSyntax) -> FakeableParameters {
        var macroParameters: FakeableParameters = FakeableParameters()
        
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for argument in arguments {
                if let label = argument.label?.text {
                    let valueExpr = argument.expression
                    
                    if label == "collectionCount",
                       let intLiteral = valueExpr.as(IntegerLiteralExprSyntax.self),
                       let intValue = Int(intLiteral.literal.text) {
                        macroParameters.collectionCount = intValue
                    } else if label == "behindPreprocessorFlag" {
                        let stringLiteral = valueExpr.as(StringLiteralExprSyntax.self)
                        macroParameters.behindPreprocessorFlag = stringLiteral?.segments.first?.description
                    }
                }
            }
        }

        return macroParameters
    }

    static func parameterDefaultValue(for rawType: String, macroParameters: FakeableParameters) -> String {
        let type: String = rawType.isOptional ? String(rawType.dropLast()) : rawType

        if type.isTuple {
            let elements = type.tupleElements.map { parameterDefaultValue(for: $0, macroParameters: macroParameters) }
            return "(\(elements.joined(separator: ", ")))"
        }
        
        if type.isDictionary {
            let (keyType, valueType) = type.dictionaryKeyValue

            let pairs = (0..<macroParameters.collectionCount)
                .map { _ in
                    let key = Randomiser.randomValue(for: keyType)
                    let value = parameterDefaultValue(for: valueType, macroParameters: macroParameters) // RÃ©cursion pour gÃ©rer `[String: [Int]]`
                    return "\(key): \(value)"
                }
                .joined(separator: ", ")

            return "[\(pairs)]"
        }
    
        if type.isCollection {
            let elementType = type.collectionType // Extraction du type interne

            let elements = (0..<macroParameters.collectionCount)
                .map { _ in parameterDefaultValue(for: elementType, macroParameters: macroParameters) } // RÃ©cursion pour les `Array` imbriquÃ©s
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


