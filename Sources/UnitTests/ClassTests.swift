import Testing
import MacroTesting
@testable import FakeableMacros

@Suite(
    .macros(
        record: .missing, // Record only missing snapshots
        macros: ["Fakeable": FakeableMacro.self]
    )
)
struct ClassTests {
    @Test
    func testClassBasicWithoutParameters() {
        assertMacro {
          """
          @Fakeable
          class Address {
              let street: String
              let city: String?
              let zipCode: Int?
              let date: Date
          }
          """
        } expansion: {
            """
            class Address {
                let street: String
                let city: String?
                let zipCode: Int?
                let date: Date

                #if DEBUG
                static func fake(
                    street: String = UUID().uuidString,
                    city: String? = UUID().uuidString,
                    zipCode: Int? = Int.random(in: -1000 ... 1000),
                    date: Date = Calendar.current.date(from: DateComponents(year: Int.random(in: 1970 ... 2030), month: Int.random(in: 1 ... 12), day: Int.random(in: 1 ... 28)))!
                ) -> Address {
                    return Address(
                        street: street,
                    city: city,
                    zipCode: zipCode,
                    date: date
                    )
                }
                #endif
            }
            """
        }
    }

    @Test
    func testClassBasicBehindPreprocessorFlagNil() {
        assertMacro {
          """
          @Fakeable(behindPreprocessorFlag: nil)
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
          """
        } expansion: {
            """
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

                #if DEBUG
                static func fake(
                    city: String? = UUID().uuidString,
                    zipCode: Int? = Int.random(in: -1000 ... 1000),
                    date: Date = Calendar.current.date(from: DateComponents(year: Int.random(in: 1970 ... 2030), month: Int.random(in: 1 ... 12), day: Int.random(in: 1 ... 28)))!,
                    array: [String] = [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString]
                ) -> MyClass {
                    return MyClass(
                        city: city,
                    zipCode: zipCode,
                    date: date,
                    array: array
                    )
                }
                #endif
            }
            """
        }
    }

    @Test
    func testEnumBasicBehindPreprocessorFlagCustom() {
        assertMacro {
          """
          @Fakeable(behindPreprocessorFlag: "CUSTOMDEBUG")
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
          """
        } expansion: {
            """
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

                #if CUSTOMDEBUG
                static func fake(
                    city: String? = UUID().uuidString,
                    zipCode: Int? = Int.random(in: -1000 ... 1000),
                    date: Date = Calendar.current.date(from: DateComponents(year: Int.random(in: 1970 ... 2030), month: Int.random(in: 1 ... 12), day: Int.random(in: 1 ... 28)))!,
                    array: [String] = [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString]
                ) -> MyClass {
                    return MyClass(
                        city: city,
                    zipCode: zipCode,
                    date: date,
                    array: array
                    )
                }
                #endif
            }
            """
        }
    }

    @Test
    func testEnumBasicCollectionCountCustom() {
        assertMacro {
          """
          @Fakeable(collectionCount: 2)
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
          """
        } expansion: {
            """
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

                #if DEBUG
                static func fake(
                    city: String? = UUID().uuidString,
                    zipCode: Int? = Int.random(in: -1000 ... 1000),
                    date: Date = Calendar.current.date(from: DateComponents(year: Int.random(in: 1970 ... 2030), month: Int.random(in: 1 ... 12), day: Int.random(in: 1 ... 28)))!,
                    array: [String] = [UUID().uuidString, UUID().uuidString]
                ) -> MyClass {
                    return MyClass(
                        city: city,
                    zipCode: zipCode,
                    date: date,
                    array: array
                    )
                }
                #endif
            }
            """
        }
    }

    @Test
    func testClassComplex() {
        assertMacro {
          """
          @Fakeable
          class MyClass {
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
          """
        } expansion: {
            #"""
            class MyClass {
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

                #if DEBUG
                static func fake(
                    id: String = UUID().uuidString,
                    name: String? = UUID().uuidString,
                    age: Int? = Int.random(in: -1000 ... 1000),
                    address: Address? = Address.fake(),
                    optionalInt: Int? = Int.random(in: -1000 ... 1000),
                    url: URL? = URL(string: "https://www.\(UUID().uuidString.prefix(8)).com")!,
                    uuid: UUID? = UUID(),
                    data: Data? = Data((0 ..< 10).map { _ in
                            UInt8.random(in: 0 ... 255)
                        }),
                    decimal: Decimal? = Decimal(Double.random(in: -1000 ... 1000)),
                    timeInterval: TimeInterval? = TimeInterval(Double.random(in: 0 ... 86400)),
                    indexPath: IndexPath? = IndexPath(index: .random(in: (0 ..< 1000))),
                    indexSet: IndexSet? = IndexSet(arrayLiteral: Int.random(in: 0 ... 10)),
                    locale: Locale? = Locale(identifier: ["en_US", "fr_FR", "de_DE"].randomElement()!),
                    measurement: Measurement<UnitLength>? = Measurement(value: Double.random(in: 0 ... 1000), unit: UnitLength.meters),
                    intValue: Int = Int.random(in: -1000 ... 1000),
                    doubleValue: Double = Double.random(in: -1000 ... 1000),
                    floatValue: Float = Float.random(in: -1000 ... 1000),
                    cgFloatValue: CGFloat = CGFloat(Float.random(in: -1000 ... 1000)),
                    uintValue: UInt = UInt.random(in: 0 ... 1000),
                    boolValue: Bool = Bool.random(),
                    optionalIntValue: Int? = Int.random(in: -1000 ... 1000),
                    optionalDoubleValue: Double? = Double.random(in: -1000 ... 1000),
                    optionalFloatValue: Float? = Float.random(in: -1000 ... 1000),
                    optionalCGFloatValue: CGFloat? = CGFloat(Float.random(in: -1000 ... 1000)),
                    optionalUIntValue: UInt? = UInt.random(in: 0 ... 1000),
                    optionalBoolValue: Bool? = Bool.random(),
                    nsString: NSString? = (UUID().uuidString) as NSString,
                    nsData: NSData? = Data((0 ..< 10).map { _ in
                            UInt8.random(in: 0 ... 255)
                        }) as NSData,
                    nsDate: NSDate? = (Calendar.current.date(from: DateComponents(year: Int.random(in: 1970 ... 2030), month: Int.random(in: 1 ... 12), day: Int.random(in: 1 ... 28)))!) as NSDate,
                    nsNumber: NSNumber? = NSNumber(value: Int.random(in: 0 ... 1000)),
                    array1: [String]? = [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString],
                    array2: [Address]? = [Address.fake(), Address.fake(), Address.fake(), Address.fake(), Address.fake()],
                    optionalArray: [Address]? = [Address.fake(), Address.fake(), Address.fake(), Address.fake(), Address.fake()],
                    set1: Set<String>? = Set(arrayLiteral: UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString),
                    set2: Set<Int>? = Set(arrayLiteral: Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000)),
                    dictionary1: [String: Int]? = [UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000)],
                    dictionary2: [String: Address]? = [UUID().uuidString: Address.fake(), UUID().uuidString: Address.fake(), UUID().uuidString: Address.fake(), UUID().uuidString: Address.fake(), UUID().uuidString: Address.fake()],
                    tupleValue: (String, Int)? = (UUID().uuidString, Int.random(in: -1000 ... 1000)),
                    nestedDictionary: [String: [Int]]? = [UUID().uuidString: [Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000)], UUID().uuidString: [Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000)], UUID().uuidString: [Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000)], UUID().uuidString: [Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000)], UUID().uuidString: [Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000), Int.random(in: -1000 ... 1000)]],
                    enumValue: MyEnum = MyEnum.fake(),
                    optionalEnumValue: MyEnum? = MyEnum.fake(),
                    arrayOfEnums: [MyEnum]? = [MyEnum.fake(), MyEnum.fake(), MyEnum.fake(), MyEnum.fake(), MyEnum.fake()],
                    dictionaryOfEnums: [String: MyEnum]? = [UUID().uuidString: MyEnum.fake(), UUID().uuidString: MyEnum.fake(), UUID().uuidString: MyEnum.fake(), UUID().uuidString: MyEnum.fake(), UUID().uuidString: MyEnum.fake()],
                    setOfEnums: Set<ChildEnum>? = Set(arrayLiteral: ChildEnum.fake(), ChildEnum.fake(), ChildEnum.fake(), ChildEnum.fake(), ChildEnum.fake())
                ) -> MyClass {
                    return MyClass(
                        id: id,
                    name: name,
                    age: age,
                    address: address,
                    optionalInt: optionalInt,
                    url: url,
                    uuid: uuid,
                    data: data,
                    decimal: decimal,
                    timeInterval: timeInterval,
                    indexPath: indexPath,
                    indexSet: indexSet,
                    locale: locale,
                    measurement: measurement,
                    intValue: intValue,
                    doubleValue: doubleValue,
                    floatValue: floatValue,
                    cgFloatValue: cgFloatValue,
                    uintValue: uintValue,
                    boolValue: boolValue,
                    optionalIntValue: optionalIntValue,
                    optionalDoubleValue: optionalDoubleValue,
                    optionalFloatValue: optionalFloatValue,
                    optionalCGFloatValue: optionalCGFloatValue,
                    optionalUIntValue: optionalUIntValue,
                    optionalBoolValue: optionalBoolValue,
                    nsString: nsString,
                    nsData: nsData,
                    nsDate: nsDate,
                    nsNumber: nsNumber,
                    array1: array1,
                    array2: array2,
                    optionalArray: optionalArray,
                    set1: set1,
                    set2: set2,
                    dictionary1: dictionary1,
                    dictionary2: dictionary2,
                    tupleValue: tupleValue,
                    nestedDictionary: nestedDictionary,
                    enumValue: enumValue,
                    optionalEnumValue: optionalEnumValue,
                    arrayOfEnums: arrayOfEnums,
                    dictionaryOfEnums: dictionaryOfEnums,
                    setOfEnums: setOfEnums
                    )
                }
                #endif
            }
            """#
        }
    }
}
