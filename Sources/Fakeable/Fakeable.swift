import FakeableParameters

/// Macro to generate fake values for a struct, class, or enum.
/// This macro can be attached to any type to generate fake data for its properties.
///
/// Parameters:
///   - collectionCount: The number of elements to generate for collections (default: `FakeableDefaultValues.collectionCount`).
///   - behindPreprocessorFlag: A string flag that can wrap the generated code in a preprocessor directive (default: `FakeableDefaultValues.behindPreprocessorFlag`).
@attached(member, names: arbitrary)
public macro Fakeable(
    /// The number of elements to generate for collections.
    collectionCount: Int = FakeableDefaultValues.collectionCount,
    /// A preprocessor flag to conditionally compile the fake method.
    behindPreprocessorFlag: String? = FakeableDefaultValues.behindPreprocessorFlag
) = #externalMacro(module: "FakeableBridge", type: "FakeableMacroBridge")
