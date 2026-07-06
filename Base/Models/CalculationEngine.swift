import Foundation

enum Token: Equatable {
    case number(Double)
    case plus, minus, multiply, divide
    case parenLeft, parenRight
    case percent
}

enum CalculationError: LocalizedError {
    case invalidExpression
    case divisionByZero
    case mismatchedParens
    case tooManyOperands

    var errorDescription: String? {
        switch self {
        case .invalidExpression: return "Incomplete expression"
        case .divisionByZero: return "Can't divide by zero"
        case .mismatchedParens: return "Unmatched parenthesis"
        case .tooManyOperands: return "Incomplete expression"
        }
    }
}

struct CalculationEngine {
    static func tokenize(_ input: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(input)
        var i = 0

        while i < chars.count {
            let c = chars[i]
            if c.isWhitespace { i += 1; continue }

            if c == "+" { tokens.append(.plus); i += 1; continue }
            if c == "−" || c == "-" {
                // Unary minus: at the start, or right after an operator or "(".
                let isUnary: Bool
                switch tokens.last {
                case nil, .plus, .minus, .multiply, .divide, .parenLeft: isUnary = true
                default: isUnary = false
                }
                if isUnary {
                    // Check if followed by (  → emit -1 × instead.
                    var j = i + 1
                    while j < chars.count && chars[j].isWhitespace { j += 1 }
                    if j < chars.count && chars[j] == "(" {
                        tokens.append(.number(-1))
                        tokens.append(.multiply)
                        i += 1
                        continue
                    }
                    var numStr = "-"
                    while j < chars.count && (chars[j].isNumber || chars[j] == "." || chars[j] == ",") {
                        if chars[j] == "," { j += 1; continue }
                        numStr.append(chars[j])
                        j += 1
                    }
                    if let num = Double(numStr) {
                        tokens.append(.number(num))
                        i = j
                        continue
                    }
                }
                tokens.append(.minus); i += 1; continue
            }
            if c == "×" || c == "*" { tokens.append(.multiply); i += 1; continue }
            if c == "÷" || c == "/" { tokens.append(.divide); i += 1; continue }
            if c == "(" { tokens.append(.parenLeft); i += 1; continue }
            if c == ")" { tokens.append(.parenRight); i += 1; continue }
            if c == "%" { tokens.append(.percent); i += 1; continue }

            if c.isNumber || c == "." {
                var numStr = ""
                while i < chars.count && (chars[i].isNumber || chars[i] == "." || chars[i] == ",") {
                    if chars[i] == "," { i += 1; continue }
                    numStr.append(chars[i])
                    i += 1
                }
                if let num = Double(numStr) {
                    tokens.append(.number(num))
                }
                continue
            }
            i += 1
        }
        return tokens
    }

    static func parse(_ tokens: [Token]) throws -> [Token] {
        var output: [Token] = []
        var operators: [Token] = []

        for token in tokens {
            switch token {
            case .number:
                output.append(token)
            case .plus, .minus, .multiply, .divide, .percent:
                while let last = operators.last, last != .parenLeft {
                    let prec1 = Self.precedence(of: token)
                    let prec2 = Self.precedence(of: last)
                    if prec2 > prec1 || (prec2 == prec1 && token != .parenLeft) {
                        output.append(operators.removeLast())
                    } else {
                        break
                    }
                }
                operators.append(token)
            case .parenLeft:
                operators.append(token)
            case .parenRight:
                while let last = operators.last, last != .parenLeft {
                    output.append(operators.removeLast())
                }
                guard operators.last == .parenLeft else {
                    throw CalculationError.mismatchedParens
                }
                operators.removeLast()
            }
        }

        while let op = operators.last, op != .parenLeft {
            output.append(operators.removeLast())
        }
        if operators.last == .parenLeft {
            throw CalculationError.mismatchedParens
        }

        return output
    }

    static func evaluate(_ rpn: [Token]) throws -> Double {
        var stack: [Double] = []

        for token in rpn {
            switch token {
            case .number(let v):
                stack.append(v)
            case .percent:
                // Postfix unary: x% = x / 100
                guard let a = stack.popLast() else { throw CalculationError.invalidExpression }
                stack.append(a / 100)
            case .plus, .minus, .multiply, .divide:
                guard stack.count >= 2 else { throw CalculationError.invalidExpression }
                let b = stack.removeLast()
                let a = stack.removeLast()
                switch token {
                case .plus: stack.append(a + b)
                case .minus: stack.append(a - b)
                case .multiply: stack.append(a * b)
                case .divide:
                    guard b != 0 else { throw CalculationError.divisionByZero }
                    stack.append(a / b)
                default: break
                }
            case .parenLeft, .parenRight:
                break
            }
        }

        guard stack.count == 1 else { throw CalculationError.tooManyOperands }
        return stack[0]
    }

    /// Typed result for callers that need to distinguish success from failure.
    static func computeValue(_ input: String) -> Result<Double, CalculationError> {
        let tokens = tokenize(input)
        guard !tokens.isEmpty else { return .failure(.invalidExpression) }
        do {
            let rpn = try parse(tokens)
            let value = try evaluate(rpn)
            guard value.isFinite else { return .failure(.divisionByZero) }
            return .success(value)
        } catch let error as CalculationError {
            return .failure(error)
        } catch {
            return .failure(.invalidExpression)
        }
    }

    static func compute(_ input: String) -> String {
        guard !input.trimmingCharacters(in: .whitespaces).isEmpty else { return "" }
        switch computeValue(input) {
        case .success(let value): return String.from(value)
        case .failure(let error): return error.localizedDescription
        }
    }

    private static func precedence(of token: Token) -> Int {
        switch token {
        case .plus, .minus: return 1
        case .multiply, .divide: return 2
        case .percent: return 3 // postfix unary binds tightest
        default: return 0
        }
    }
}

// Helper to format result cleanly
extension String {
    static func from(_ double: Double) -> String {
        guard double.isFinite else { return "—" }
        if double == floor(double) && abs(double) < 1e15 {
            return String(format: "%.0f", double)
        }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 8
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = false
        return f.string(from: NSNumber(value: double)) ?? String(double)
    }
}
