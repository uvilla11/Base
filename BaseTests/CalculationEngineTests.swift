import XCTest
@testable import Base

final class CalculationEngineTests: XCTestCase {
    func testAddition() {
        XCTAssertEqual(CalculationEngine.compute("2+3"), "5")
    }

    func testSubtraction() {
        XCTAssertEqual(CalculationEngine.compute("10−4"), "6")
    }

    func testMultiplication() {
        XCTAssertEqual(CalculationEngine.compute("3×4"), "12")
    }

    func testDivision() {
        XCTAssertEqual(CalculationEngine.compute("10÷2"), "5")
    }

    func testDecimal() {
        XCTAssertEqual(CalculationEngine.compute("5÷2"), "2.5")
    }

    func testOperatorPrecedence() {
        XCTAssertEqual(CalculationEngine.compute("2+3×4"), "14")
    }

    func testParentheses() {
        XCTAssertEqual(CalculationEngine.compute("(2+3)×4"), "20")
    }

    func testNestedParens() {
        XCTAssertEqual(CalculationEngine.compute("((2+3)×2)"), "10")
    }

    func testDivisionByZero() {
        let result = CalculationEngine.compute("5÷0")
        XCTAssertTrue(result.contains("zero"))
    }

    func testMismatchedParens() {
        let result = CalculationEngine.compute("(2+3")
        XCTAssertTrue(result.contains("parenthesis"))
    }

    func testDecimalInput() {
        XCTAssertEqual(CalculationEngine.compute("2.5+2.5"), "5")
    }

    func testPercent() {
        XCTAssertEqual(CalculationEngine.compute("200×10%"), "20")
    }

    func testChainOperations() {
        XCTAssertEqual(CalculationEngine.compute("2+3+4"), "9")
        XCTAssertEqual(CalculationEngine.compute("10−2−3"), "5")
    }

    func testHyphenMinus() {
        XCTAssertEqual(CalculationEngine.compute("10-4"), "6")
    }

    func testAsteriskMultiply() {
        XCTAssertEqual(CalculationEngine.compute("3*4"), "12")
    }

    func testSlashDivide() {
        XCTAssertEqual(CalculationEngine.compute("10/2"), "5")
    }

    func testUnaryMinus() {
        XCTAssertEqual(CalculationEngine.compute("−5+3"), "-2")
        XCTAssertEqual(CalculationEngine.compute("2×-3"), "-6")
    }

    func testUnaryMinusWithParens() {
        XCTAssertEqual(CalculationEngine.compute("-(5+2)"), "-7")
        XCTAssertEqual(CalculationEngine.compute("5+-(3+2)"), "0")
        XCTAssertEqual(CalculationEngine.compute("- (5)"), "-5")
    }

    func testLargeNumber() {
        let result = CalculationEngine.compute("999999×999999")
        XCTAssertFalse(result.contains("Error"))
    }

    func testEmptyInput() {
        XCTAssertEqual(CalculationEngine.compute(""), "")
        XCTAssertEqual(CalculationEngine.compute("   "), "")
    }

    func testStringFrom() {
        XCTAssertEqual(String.from(2.5), "2.5")
        XCTAssertEqual(String.from(100), "100")
        XCTAssertEqual(String.from(0.1), "0.1")
        XCTAssertEqual(String.from(0.33333333), "0.33333333")
    }
}
