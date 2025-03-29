import FakeableParameters
import SwiftSyntax

extension FakeableMacro {
    /// Injects a fake method for a struct or class.
    /// - Parameters:
    ///   - structName: The name of the struct or class for which the fake method is generated.
    ///   - properties: A list of tuples containing property names and their corresponding types.
    ///   - macroParameters: Additional parameters controlling macro behavior, like preprocessor flags.
    /// - Returns: An array of `DeclSyntax` containing the fake method, which can be injected into the struct or class.
    static func injectFakeMethod(
        structName: String,
        properties: [(String, String)],
        macroParameters: FakeableParameters
    ) -> [DeclSyntax] {
        // Generate parameter definitions for the fake method.
        // Each property is transformed into a defaulted parameter in the method.
        let paramDefinitions: String = properties
            .map { name, type in
                // Each parameter gets a default value based on its type and macro parameters.
                "\(name): \(type) = \(parameterDefaultValue(for: type, macroParameters: macroParameters))"
            }
            .joined(separator: ",\n    ")  // Joining parameters into a string with indentation for readability.

        // Generate the assignments that will initialize the struct or class with the provided properties.
        let assignments: String = properties
            .map { name, _ in "\(name): \(name)" }  // Create an assignment for each property (name = name).
            .joined(separator: ",\n    ")  // Joining assignments into a string with indentation.

        // Define the body of the fake method that constructs an instance of the struct/class.
        var fakeMethod: String = """
        static func fake(
            \(paramDefinitions)
        ) -> \(structName) {
            return \(structName)(
                \(assignments)
            )
        }
        """

        // If a preprocessor flag is provided, wrap the method in the preprocessor directive.
        if let flag = macroParameters.behindPreprocessorFlag {
            fakeMethod = "#if \(flag)\n\(fakeMethod)\n#endif"  // Adding the preprocessor condition.
        }

        // Return the generated fake method as DeclSyntax, which can be injected into the code.
        return [DeclSyntax(stringLiteral: fakeMethod)]
    }

    /// Extracts property names and types from the declaration syntax.
    /// This function processes the member items of a type (e.g., struct or class) to extract the property names and their respective types.
    /// - Parameter itemList: The list of member block items (typically the members of a struct or class).
    /// - Returns: An array of tuples, where each tuple contains a property name and its corresponding type.
    static func extractProperties(from itemList: MemberBlockItemListSyntax) -> [(String, String)] {
        // Process each member in the item list, extracting properties (variables).
        itemList
            .compactMap { member in
                // Check if the member is a property (VariableDeclSyntax).
                if let property = member.decl.as(VariableDeclSyntax.self) {
                    // Extract the identifier (name) of the property.
                    if let identifier = property.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                       // Extract the type annotation of the property.
                       let type = property.bindings.first?.typeAnnotation?.type.description {
                        // Return a tuple containing the property name and type.
                        return (identifier, type)
                    } else {
                        // If no valid identifier or type, return nil.
                        return nil
                    }
                } else {
                    // If the member is not a property, return nil.
                    return nil
                }
            }
    }
}
