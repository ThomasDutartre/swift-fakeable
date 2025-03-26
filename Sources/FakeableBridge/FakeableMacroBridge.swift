import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import FakeableMacros

@main
struct FakeableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FakeableMacroBridge.self
    ]
}

public struct FakeableMacroBridge: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try FakeableMacro.expansion(of: node, providingMembersOf: declaration, in: context)
    }
}


