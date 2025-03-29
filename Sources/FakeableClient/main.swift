import Fakeable
import Foundation

@Fakeable(collectionCount: 3, behindPreprocessorFlag: nil)
struct Address {
    let street: String
    let city: String?
    let zipCode: Int?
    let date: Date
    let array: [String]
}

@Fakeable
class MyClass {
    let city: String?
    let zipCode: Int?
    let date: Date
    let array: [String]

    public init(city: String?, zipCode: Int?, date: Date, array: [String]) {
        self.city = city
        self.zipCode = zipCode
        self.date = date
        self.array = array
    }
}

@Fakeable
struct MyStruct {
    let id: String
    let name: String?
    let age: Int?
    let address: Address?
    let optionalInt: Int?

    let url: URL?
    let uuid: UUID?
    let data: Data?
    let decimal: Decimal?
    let timeInterval: TimeInterval?
    let indexPath: IndexPath?
    let indexSet: IndexSet?
    let locale: Locale?
    let measurement: Measurement<UnitLength>?

    let intValue: Int
    let doubleValue: Double
    let floatValue: Float
    let cgFloatValue: CGFloat
    let uintValue: UInt
    let boolValue: Bool

    let optionalIntValue: Int?
    let optionalDoubleValue: Double?
    let optionalFloatValue: Float?
    let optionalCGFloatValue: CGFloat?
    let optionalUIntValue: UInt?
    let optionalBoolValue: Bool?

    let nsString: NSString?
    let nsData: NSData?
    let nsDate: NSDate?
    let nsNumber: NSNumber?

    let array1: [String]?
    let array2: [Address]?
    let optionalArray: [Address]?
    let set1: Set<String>?
    let set2: Set<Int>?
    let dictionary1: [String: Int]?
    let dictionary2: [String: Address]?

    let tupleValue: (String, Int)?
    let nestedDictionary: [String: [Int]]?
    let enumValue: MyEnum
    let optionalEnumValue: MyEnum?
    let arrayOfEnums: [MyEnum]?
    let dictionaryOfEnums: [String: MyEnum]?
    let setOfEnums: Set<ChildEnum>?
}

@Fakeable
enum MyEnum {
    case fake
    case real(abc: String)
    case address(test: Address)
    case complex(name: String, age: Int, isActive: Bool)
    case enumInEnum(child: ChildEnum)
    case enumOpt(child: String?)
    case array(array: [String])
    case arrayOpt(array: [String]?)

    case int(value: Int)
    case double(value: Double)
    case bool(value: Bool)
    case optionalInt(value: Int?)
    case optionalBool(value: Bool?)
    case tuple(value: (String, Int))
    case dictionary(value: [String: Int])
    case set(value: Set<String>)
    case enumWithCustomType(value: Address)
    case multipleParams(id: Int, title: String, isValid: Bool)
}

// Not handled cases :
//    let nestedArray: [[String]]?
//    let nestedOptionalArray: [[String]?]?
//    case nestedArray(value: [[String]])

@Fakeable
enum ChildEnum: String {
    case child = "abc"
    case sister = "sis"
}

for _ in 0..<10 {
    print(MyStruct.fake(id: "1", name: nil))
    print(MyEnum.fake())
    print(MyClass.fake())
}
