import SwiftSyntax
import FakeableParameters

extension FakeableMacro {
    static func injectFakeMethod(
        structName: String,
        properties: [(String, String)],
        macroParameters: FakeableParameters
    ) -> [DeclSyntax] {
        let paramDefinitions: String = properties
            .map { name, type in
                "\(name): \(type) = \(parameterDefaultValue(for: type, macroParameters: macroParameters))"
            }
            .joined(separator: ",\n    ")

        let assignments: String = properties
            .map { name, _ in
                "\(name): \(name)"
            }
            .joined(separator: ",\n    ")

        var fakeMethod: String = """
        static func fake(
            \(paramDefinitions)
        ) -> \(structName) {
            return \(structName)(
                \(assignments)
            )
        }
        """
        
        if let behindPreprocessorFlag = macroParameters.behindPreprocessorFlag {
            fakeMethod = """
            #if \(behindPreprocessorFlag)
            \(fakeMethod)
            #endif
            """
        }

        return [DeclSyntax(stringLiteral: fakeMethod)]
    }
    
//    private static func extractProperties(from structDecl: StructDeclSyntax) -> [(String, String)] {
//        structDecl.memberBlock.members
//            .compactMap { member in
//                if let property = member.decl.as(VariableDeclSyntax.self),
//                   let identifier = property.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
//                   let type = property.bindings.first?.typeAnnotation?.type.description {
//                    return (identifier, type)
//                } else {
//                    return nil
//                }
//            }
//    }
}


