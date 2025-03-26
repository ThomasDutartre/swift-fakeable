import FakeableParameters

@attached(member, names: arbitrary)
public macro Fakeable(
    collectionCount: Int = FakeableDefaultValues.collectionCount,
    behindPreprocessorFlag: String? = FakeableDefaultValues.behindPreprocessorFlag
) = #externalMacro(module: "FakeableBridge", type: "FakeableMacroBridge")


