struct Randomiser {
    private static let commonTypes: [String: String] = [
        "String": "UUID().uuidString",
        "Int": "Int.random(in: -1000...1000)",
        "Double": "Double.random(in: -1000...1000)",
        "Float": "Float.random(in: -1000...1000)",
        "Decimal": "Decimal(Double.random(in: -1000...1000))",
        "Bool": "Bool.random()",
        "Date": "Calendar.current.date(from: DateComponents(year: Int.random(in: 1970...2030), month: Int.random(in: 1...12), day: Int.random(in: 1...28)))!",
        "URL": "URL(string: \"https://www.\\(UUID().uuidString.prefix(8)).com\")!"
    ]

    static func randomValue(for type: String) -> String {
        if let predefinedValue = commonTypes[type] {
            return predefinedValue
        }

        switch type {
        case "NSString":
            return "(\(commonTypes["String"]!)) as NSString"
        case "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            return "UInt.random(in: 0...1000)"
        case "CGFloat":
            return "CGFloat(Float.random(in: -1000...1000))"
        case "NSDate":
            return "(\(commonTypes["Date"]!)) as NSDate"
        case "UUID":
            return "UUID()"
        case "Data":
            return "Data((0..<10).map { _ in UInt8.random(in: 0...255) })"
        case "NSData":
            return "Data((0..<10).map { _ in UInt8.random(in: 0...255) }) as NSData"
        case "TimeInterval":
            return "TimeInterval(Double.random(in: 0...86400))"
        case "IndexPath":
            return "IndexPath(index: .random(in: (0..<1000)))"
        case "IndexSet":
            return "IndexSet(arrayLiteral: Int.random(in: 0...10))"
        case "Locale":
            return "Locale(identifier: [\"en_US\", \"fr_FR\", \"de_DE\"].randomElement()!)"
        case "Measurement<UnitLength>":
            return "Measurement(value: Double.random(in: 0...1000), unit: UnitLength.meters)"
        case "NSNumber":
            return "NSNumber(value: Int.random(in: 0...1000))"
        default:
            return "\(type).fake()"
        }
    }
}
