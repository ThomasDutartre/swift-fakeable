import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import FakeableMacros

/// Main plugin for the Fakeable macro.
/// This plugin integrates the custom macros into the compilation process.
@main
struct FakeableMacroPlugin: CompilerPlugin {
    // List of macros provided by the plugin. Here, we use the `FakeableMacroBridge`.
    let providingMacros: [Macro.Type] = [
        FakeableMacroBridge.self  // Registering the macro bridge to be used in the compilation process.
    ]
}

/// This struct acts as a "bridge" between the macro code and its usage within the compilation context.
/// It allows the Fakeable macro to be applied to source code declarations.
public struct FakeableMacroBridge: MemberMacro {
    /// Main function for expanding the Fakeable macro.
    /// This is called to apply the macro transformation to a code element.
    /// - Parameters:
    ///   - node: The syntax node of the macro attribute.
    ///   - declaration: The declaration to which the macro is applied.
    ///   - context: The context in which the macro expansion is performed.
    /// - Returns: An array of `DeclSyntax` containing the transformed declarations after the macro is applied.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Apply the expansion of the `FakeableMacro` here. This allows the macro to transform the target
        // declaration (like a struct or enum) using the provided parameters.
        try FakeableMacro.expansion(of: node, providingMembersOf: declaration, in: context)
    }
}
