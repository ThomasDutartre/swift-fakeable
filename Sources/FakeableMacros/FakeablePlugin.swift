import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

struct FakeableMacrosPlugin: CompilerPlugin {
    // Define the macros that this plugin provides
    let providingMacros: [Macro.Type] = [
        FakeableMacro.self
    ]
}
