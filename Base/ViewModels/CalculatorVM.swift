import SwiftUI
import Foundation

@Observable
final class CalculatorVM {
    /// The full line shown in the display: expression so far + number being typed.
    private(set) var display = "0"
    /// Live preview of the result while typing (shown small above the display).
    private(set) var preview = ""
    /// True when the display shows a completed result.
    private(set) var showingResult = false
    /// True when the last evaluation failed.
    private(set) var hasError = false

    var history = HistoryRing()

    private var expression = ""     // committed tokens, e.g. "12 + 3 × "
    private var currentNumber = ""  // digits being typed
    private var justEvaluated = false

    // MARK: Input

    func inputDigit(_ digit: String) {
        if justEvaluated || hasError { softClear() }
        if digit == "." {
            if currentNumber.contains(".") { return }
            if currentNumber.isEmpty { currentNumber = "0" }
        }
        if currentNumber == "0" && digit != "." {
            currentNumber = digit
        } else {
            currentNumber.append(digit)
        }
        refresh()
    }

    func inputOperator(_ symbol: String) {
        guard ["+", "−", "×", "÷"].contains(symbol) else { return }
        if hasError { clear(); return }
        justEvaluated = false

        if currentNumber.isEmpty {
            if expression.hasSuffix(" ") {
                // Replace the pending operator.
                expression = String(expression.dropLast(3)) + " \(symbol) "
            } else if expression.isEmpty && symbol == "−" {
                // Leading minus starts a negative number.
                currentNumber = "-"
            }
        } else {
            expression += currentNumber + " \(symbol) "
            currentNumber = ""
        }
        refresh()
    }

    func evaluate() {
        guard !hasError else { clear(); return }
        let candidate = (expression + currentNumber).trimmingCharacters(in: .whitespaces)
        guard !candidate.isEmpty, !candidate.hasSuffix("+"), !candidate.hasSuffix("−"),
              !candidate.hasSuffix("×"), !candidate.hasSuffix("÷") else { return }

        switch CalculationEngine.computeValue(candidate) {
        case .success(let value):
            let resultString = Format.pretty(value)
            history.append(Expression(id: UUID(), input: candidate,
                                      result: resultString, timestamp: Date()))
            display = resultString
            preview = ""
            expression = ""
            currentNumber = rawString(value)
            showingResult = true
            justEvaluated = true
        case .failure(let error):
            display = error.localizedDescription
            preview = ""
            hasError = true
        }
    }

    func clear() {
        expression = ""
        currentNumber = ""
        display = "0"
        preview = ""
        showingResult = false
        hasError = false
        justEvaluated = false
    }

    func backspace() {
        if justEvaluated || hasError { clear(); return }
        if !currentNumber.isEmpty {
            currentNumber = String(currentNumber.dropLast())
        } else if expression.hasSuffix(" ") {
            // Delete the pending operator, resume editing the previous number.
            expression = String(expression.dropLast(3))
            if let range = expression.range(of: " ", options: .backwards) {
                currentNumber = String(expression[range.upperBound...])
                expression = String(expression[..<range.upperBound])
            } else {
                currentNumber = expression
                expression = ""
            }
        }
        refresh()
    }

    func inputPercent() {
        guard let value = Double(currentNumber) else { return }
        currentNumber = rawString(value / 100)
        justEvaluated = false
        refresh()
    }

    func toggleSign() {
        if justEvaluated { justEvaluated = false }
        if currentNumber.hasPrefix("-") {
            currentNumber = String(currentNumber.dropFirst())
        } else if !currentNumber.isEmpty && currentNumber != "0" {
            currentNumber = "-" + currentNumber
        }
        refresh()
    }

    /// Load a past result back into the input line.
    func recall(_ expr: Expression) {
        clear()
        if let value = Double(expr.result.replacingOccurrences(of: ",", with: "")) {
            currentNumber = rawString(value)
        }
        refresh()
    }

    func clearHistory() { history.clear() }
    func removeFromHistory(_ expr: Expression) { history.remove(expr) }

    // MARK: Private

    /// Reset for new input after a result, keeping history.
    private func softClear() {
        expression = ""
        currentNumber = ""
        showingResult = false
        hasError = false
        justEvaluated = false
    }

    private func refresh() {
        showingResult = false
        let line = expression + currentNumber
        display = line.isEmpty ? "0" : line

        // Live result preview when there's a complete binary expression.
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if !currentNumber.isEmpty && expression.contains(" "),
           case .success(let value) = CalculationEngine.computeValue(trimmed) {
            preview = Format.pretty(value)
        } else {
            preview = ""
        }
    }

    private func rawString(_ value: Double) -> String {
        if value == value.rounded() && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        return String(value)
    }
}
