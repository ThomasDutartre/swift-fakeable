public enum FakeableDefaultValues {
    public static let collectionCount = 5
    public static let behindPreprocessorFlag = "DEBUG"
}

public struct FakeableParameters: Sendable {
    public var collectionCount: Int
    public var behindPreprocessorFlag: String?

    public init(
        collectionCount: Int = FakeableDefaultValues.collectionCount,
        behindPreprocessorFlag: String = FakeableDefaultValues.behindPreprocessorFlag
    ) {
        self.collectionCount = collectionCount
        self.behindPreprocessorFlag = behindPreprocessorFlag
    }
}
