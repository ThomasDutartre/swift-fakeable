import SwiftSyntax
import FakeableParameters

extension FakeableMacro {
    static func injectFakeMethod(
        _ enumDecl: EnumDeclSyntax,
        macroParameters: FakeableParameters
    ) -> [DeclSyntax] {
        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap { caseDecl in
                caseDecl.elements.map { element in
                    (element.name.text, element.parameterClause?.parameters.map {
                        ($0.firstName!.text, $0.type.description)
                    } ?? [])
                }
            }

        let randomCases = cases
            .map { generateCaseExpression(caseName: $0.0, params: $0.1, macroParameters: macroParameters) }
            .joined(separator: ",\n")

        var fakeMethod = """
        static func fake(forcedCase: \(enumDecl.name.text)? = nil) -> \(enumDecl.name.text) {
            if let forcedCase = forcedCase {
                return forcedCase
            }

            let cases: [() -> \(enumDecl.name.text)] = [
                \(randomCases)
            ]
            return cases.randomElement()!()
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
    
    private static func generateCaseExpression(
        caseName: String,
        params: [(String, String)],
        macroParameters: FakeableParameters
    ) -> String {
        guard !params.isEmpty else { return "{ .\(caseName) }" }
        let paramValues = params.map { "\($0.0): \(parameterDefaultValue(for: $0.1, macroParameters: macroParameters))" }
        return "{ .\(caseName)(\(paramValues.joined(separator: ", "))) }"
    }
}


