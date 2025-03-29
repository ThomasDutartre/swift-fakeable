import Foundation

public extension String {

    var isOptional: Bool {
        self.last == "?"
    }

    var isArray: Bool {
        self.first == "[" && self.last == "]" && !self.isDictionary
    }

    var isSet: Bool {
        self.contains("Set<") && self.last == ">"
    }

    var isCollection: Bool {
        self.isArray || self.isSet
    }

    var isDictionary: Bool {
        self.hasPrefix("[") && self.contains(":") && self.hasSuffix("]")
    }

    var isTuple: Bool {
        self.hasPrefix("(") && self.hasSuffix(")") && self.contains(",")
    }

    var collectionType: String {
        guard isCollection else { return self }

        var trimmed = self.trimmingCharacters(in: .whitespaces)

        if isArray {
            trimmed.removeFirst() // Supprime `[`
            trimmed.removeLast()  // Supprime `]`
        } else if isSet {
            trimmed = trimmed
                .replacingOccurrences(of: "Set<", with: "")
                .replacingOccurrences(of: ">", with: "")
        }

        return trimmed.isCollection ? trimmed.collectionType : trimmed
    }

    var dictionaryKeyValue: (String, String) {
        guard isDictionary else { return ("String", "Any") }

        // Supprimer les crochets externes
        let trimmed = self.dropFirst().dropLast()

        // Trouver l'index du `:` principal
        var bracketLevel = 0
        var colonIndex: String.Index?

        for index in trimmed.indices {
            let char = trimmed[index]
            if char == "[" { bracketLevel += 1 }
            if char == "]" { bracketLevel -= 1 }
            if char == ":" && bracketLevel == 0 {
                colonIndex = index
                break
            }
        }

        guard let colonIndex = colonIndex else { return ("String", "Any") }

        let keyType = trimmed[..<colonIndex].trimmingCharacters(in: .whitespaces)
        let valueType = trimmed[trimmed.index(after: colonIndex)...].trimmingCharacters(in: .whitespaces)

        return (String(keyType), String(valueType))
    }

    var tupleElements: [String] {
        guard isTuple else { return [] }

        let trimmed = self.dropFirst().dropLast() // Supprimer les parenthÃ¨ses
        var elements: [String] = []
        var bracketLevel = 0
        var start = trimmed.startIndex

        for index in trimmed.indices {
            let char = trimmed[index]
            if char == "<" || char == "[" || char == "(" { bracketLevel += 1 }
            if char == ">" || char == "]" || char == ")" { bracketLevel -= 1 }
            if char == "," && bracketLevel == 0 {
                elements.append(String(trimmed[start..<index]).trimmingCharacters(in: .whitespaces))
                start = trimmed.index(after: index)
            }
        }

        elements.append(String(trimmed[start...]).trimmingCharacters(in: .whitespaces))
        return elements
    }
}
