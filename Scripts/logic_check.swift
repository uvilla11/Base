import Foundation

func eq(_ a: String, _ b: String, _ label: String) {
    assert(a == b, "\(label): got \(a), expected \(b)")
}

// Engine
eq(CalculationEngine.compute("2+3"), "5", "add")
eq(CalculationEngine.compute("10−4"), "6", "subtract unicode")
eq(CalculationEngine.compute("10-4"), "6", "subtract ascii")
eq(CalculationEngine.compute("3×4"), "12", "multiply")
eq(CalculationEngine.compute("10÷2"), "5", "divide")
eq(CalculationEngine.compute("5÷2"), "2.5", "decimal result")
eq(CalculationEngine.compute("2+3×4"), "14", "precedence")
eq(CalculationEngine.compute("(2+3)×4"), "20", "parens")
eq(CalculationEngine.compute("-5+3"), "-2", "unary minus")
eq(CalculationEngine.compute("−5+3"), "-2", "unary unicode minus")
eq(CalculationEngine.compute("2 × -3"), "-6", "unary after op")
eq(CalculationEngine.compute("-(5+2)"), "-7", "unary paren")
eq(CalculationEngine.compute("5+-(3+2)"), "0", "unary paren after op")
eq(CalculationEngine.compute("- (5)"), "-5", "unary paren spaced")
eq(CalculationEngine.compute("200×10%"), "20", "percent op")
eq(CalculationEngine.compute("1,000+1"), "1001", "grouping separators")
assert(CalculationEngine.compute("5÷0").contains("zero"), "div by zero message")
assert(CalculationEngine.compute("(2+3").contains("parenthesis"), "mismatched parens")
if case .failure = CalculationEngine.computeValue("2+"), true {} else { assertionFailure("trailing op should fail") }

// Units
func close(_ a: Double, _ b: Double, _ label: String) {
    assert(abs(a - b) < 0.01, "\(label): got \(a), expected \(b)")
}
close(UnitConversion.convert(value: 1, from: "km", to: "m", category: .length), 1000, "km→m")
close(UnitConversion.convert(value: 1, from: "mi", to: "km", category: .length), 1.609, "mi→km")
close(UnitConversion.convert(value: 100, from: "°C", to: "°F", category: .temperature), 212, "C→F")
close(UnitConversion.convert(value: 32, from: "°F", to: "°C", category: .temperature), 0, "F→C")
close(UnitConversion.convert(value: 0, from: "°C", to: "K", category: .temperature), 273.15, "C→K")
close(UnitConversion.convert(value: 1, from: "lb", to: "oz", category: .mass), 16, "lb→oz")
close(UnitConversion.convert(value: 1, from: "gal", to: "L", category: .volume), 3.785, "gal→L")
print("Unit checks passed")
print("ALL CHECKS PASSED")

print("Engine checks passed")

// String.from
assert(String.from(2.5) == "2.5", "from 2.5")
assert(String.from(-3) == "-3", "from -3")
assert(String.from(0.33333333) == "0.33333333", "from 0.33333333")
assert(String.from(100) == "100", "from 100")
assert(String.from(Double.nan) != "0", "nan handling")
print("String.from checks passed")

// Units
