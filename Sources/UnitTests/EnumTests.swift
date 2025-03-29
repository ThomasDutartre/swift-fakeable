import Testing
import MacroTesting
@testable import FakeableMacros

@Suite(
    .macros(
        record: .missing, // Record only missing snapshots
        macros: ["Fakeable": FakeableMacro.self]
    )
)
struct EnumTests {
    @Test
    func testEnumBasicWithoutParameters() {
        assertMacro {
          """
          @Fakeable
          enum ChildEnum: String {
              case child = "abc"
              case sister = "sis"
          }
          """
        } expansion: {
            """
            enum ChildEnum: String {
                case child = "abc"
                case sister = "sis"

                #if DEBUG
                static func fake(forcedCase: ChildEnum? = nil) -> ChildEnum {
                    if let forcedCase = forcedCase {
                        return forcedCase
                    }
                    let cases: [() -> ChildEnum] = [
                        {
                            .child
                        },
                        {
                            .sister
                        }
                    ]
                    return cases.randomElement()!()
                }
                #endif
            }
            """
        }
    }

    @Test
    func testEnumBasicBehindPreprocessorFlagNil() {
        assertMacro {
          """
          @Fakeable(behindPreprocessorFlag: nil)
          enum ChildEnum: String {
              case child = "abc"
          }
          """
        } expansion: {
            """
            enum ChildEnum: String {
                case child = "abc"

                #if DEBUG
                static func fake(forcedCase: ChildEnum? = nil) -> ChildEnum {
                    if let forcedCase = forcedCase {
                        return forcedCase
                    }
                    let cases: [() -> ChildEnum] = [
                        {
                            .child
                        }
                    ]
                    return cases.randomElement()!()
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
          enum ChildEnum: String {
              case child = "abc"
          }
          """
        } expansion: {
            """
            enum ChildEnum: String {
                case child = "abc"

                #if CUSTOMDEBUG
                static func fake(forcedCase: ChildEnum? = nil) -> ChildEnum {
                    if let forcedCase = forcedCase {
                        return forcedCase
                    }
                    let cases: [() -> ChildEnum] = [
                        {
                            .child
                        }
                    ]
                    return cases.randomElement()!()
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
          enum ChildEnum: String {
                case array(array: [String])
          }
          """
        } expansion: {
            """
            enum ChildEnum: String {
                  case array(array: [String])

                  #if DEBUG
                  static func fake(forcedCase: ChildEnum? = nil) -> ChildEnum {
                      if let forcedCase = forcedCase {
                          return forcedCase
                      }
                      let cases: [() -> ChildEnum] = [
                          {
                                .array(array: [UUID().uuidString, UUID().uuidString])
                          }
                      ]
                      return cases.randomElement()!()
                  }
                  #endif
            }
            """
        }
    }

    @Test
    func testComplexEnum() {
        assertMacro {
            """
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
            """
        } expansion: {
            """
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

                #if DEBUG
                static func fake(forcedCase: MyEnum? = nil) -> MyEnum {
                    if let forcedCase = forcedCase {
                        return forcedCase
                    }
                    let cases: [() -> MyEnum] = [
                        {
                            .fake
                        },
                        {
                            .real(abc: UUID().uuidString)
                        },
                        {
                            .address(test: Address.fake())
                        },
                        {
                            .complex(name: UUID().uuidString, age: Int.random(in: -1000 ... 1000), isActive: Bool.random())
                        },
                        {
                            .enumInEnum(child: ChildEnum.fake())
                        },
                        {
                            .enumOpt(child: UUID().uuidString)
                        },
                        {
                            .array(array: [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString])
                        },
                        {
                            .arrayOpt(array: [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString])
                        },
                        {
                            .int(value: Int.random(in: -1000 ... 1000))
                        },
                        {
                            .double(value: Double.random(in: -1000 ... 1000))
                        },
                        {
                            .bool(value: Bool.random())
                        },
                        {
                            .optionalInt(value: Int.random(in: -1000 ... 1000))
                        },
                        {
                            .optionalBool(value: Bool.random())
                        },
                        {
                            .tuple(value: (UUID().uuidString, Int.random(in: -1000 ... 1000)))
                        },
                        {
                            .dictionary(value: [UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000), UUID().uuidString: Int.random(in: -1000 ... 1000)])
                        },
                        {
                            .set(value: Set(arrayLiteral: UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString))
                        },
                        {
                            .enumWithCustomType(value: Address.fake())
                        },
                        {
                            .multipleParams(id: Int.random(in: -1000 ... 1000), title: UUID().uuidString, isValid: Bool.random())
                        }
                    ]
                    return cases.randomElement()!()
                }
                #endif
            }
            """
        }
    }
}
