import FakeableParameters
import SwiftSyntax

extension FakeableMacro {
    /// Injects a fake method for an enum.
    /// - Parameters:
    ///   - enumDecl: The enum declaration syntax, which provides the structure and cases of the enum.
    ///   - macroParameters: Additional parameters controlling macro behavior, such as preprocessor flags.
    /// - Returns: An array of `DeclSyntax` containing the fake method, which can be injected into the enum.
    static func injectFakeMethod(
        _ enumDecl: EnumDeclSyntax,
        macroParameters: FakeableParameters
    ) -> [DeclSyntax] {
        // Extracting the enum cases and their associated parameters from the enum declaration.
        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }  // Extracting EnumCaseDeclSyntax
            .flatMap { caseDecl in
                // Mapping each enum case element to a tuple containing case name and its parameters
                caseDecl.elements.map { element in
                    (element.name.text, element.parameterClause?.parameters.map {
                        // Extracting the name and type of each parameter in the enum case
                        ($0.firstName!.text, $0.type.description)
                    } ?? [])
                }
            }

        // Generating random case expressions for each enum case using the extracted parameters
        let randomCases = cases
            .map { generateCaseExpression(caseName: $0.0, params: $0.1, macroParameters: macroParameters) }
            .joined(separator: ",\n")  // Joining all generated case expressions into a single string

        // Defining the structure of the fake method
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

        // Adding conditional compilation flag if provided in macro parameters
        if let flag = macroParameters.behindPreprocessorFlag {
            fakeMethod = "#if \(flag)\n\(fakeMethod)\n#endif"  // Wrap the fake method with the preprocessor flag
        }

        // Returning the fake method wrapped as DeclSyntax
        return [DeclSyntax(stringLiteral: fakeMethod)]
    }

    /// Generates an expression to create a fake case for an enum.
    /// - Parameters:
    ///   - caseName: The name of the enum case.
    ///   - params: The list of parameters for the case. If the list is empty, the case expression will not include parameters.
    ///   - macroParameters: Additional parameters controlling macro behavior.
    /// - Returns: A string representation of the case expression. If no parameters are provided, the case is created without parameters.
    static func generateCaseExpression(caseName: String, params: [(String, String)], macroParameters: FakeableParameters) -> String {
        // If no parameters are provided, return the case expression without parameters
        guard !params.isEmpty else { return "{ .\(caseName) }" }

        // If parameters are provided, construct the case expression with parameters
        let paramValues = params
            .map { "\($0.0): \(parameterDefaultValue(for: $0.1, macroParameters: macroParameters))" }
            .joined(separator: ", ")
        return "{ .\(caseName)(\(paramValues)) }"
    }

}
