import Testing
@testable import FakeableMacros

@Suite
struct StringExtensionsTests {
    
    @Test
    func testIsOptional() {
        #expect("String?".isOptional == true)
        #expect("Int?".isOptional == true)
        #expect("String".isOptional == false)
        #expect("[String]".isOptional == false)
    }

    @Test
    func testIsArray() {
        #expect("[Int]".isArray == true)
        #expect("[String]".isArray == true)
        #expect("Array<String>".isArray == false)
        #expect("String".isArray == false)
    }

    @Test
    func testIsSet() {
        #expect("Set<Int>".isSet == true)
        #expect("Set<String>".isSet == true)
        #expect("[Int]".isSet == false)
        #expect("Int".isSet == false)
    }

    @Test
    func testIsCollection() {
        #expect("[Int]".isCollection == true)
        #expect("Set<String>".isCollection == true)
        #expect("[String: Int]".isCollection == false) // Dictionnaire â‰  Collection
        #expect("Int".isCollection == false)
    }

    @Test
    func testIsDictionary() {
        #expect("[String: Int]".isDictionary == true)
        #expect("[Int: String]".isDictionary == true)
        #expect("[String: [Int]]".isDictionary == true)
        #expect("[Key: Value]".isDictionary == true)
        #expect("[String]".isDictionary == false)
    }

    @Test
    func testIsTuple() {
        #expect("(Int, String)".isTuple == true)
        #expect("(Int, (String, Bool))".isTuple == true)
        #expect("Int".isTuple == false)
        #expect("[String: Int]".isTuple == false)
    }

    @Test
    func testCollectionType() {
        #expect("[Int]".collectionType == "Int")
        #expect("Set<String>".collectionType == "String")
        #expect("[[String]]".collectionType == "String")
        #expect("Int".collectionType == "Int") // Pas une collection, retourne lui-mÃªme
    }

    @Test
    func testDictionaryKeyValue() {
        #expect("[String: Int]".dictionaryKeyValue == ("String", "Int"))
        #expect("[Int: String]".dictionaryKeyValue == ("Int", "String"))
        #expect("[String: [Int]]".dictionaryKeyValue == ("String", "[Int]"))
        #expect("[Key: Value]".dictionaryKeyValue == ("Key", "Value"))
    }

    @Test
    func testTupleElements() {
        #expect("(Int, String)".tupleElements == ["Int", "String"])
        #expect("(Int, (String, Bool))".tupleElements == ["Int", "(String, Bool)"])
        #expect("(String, (Int, [Bool]))".tupleElements == ["String", "(Int, [Bool])"])
    }
}


