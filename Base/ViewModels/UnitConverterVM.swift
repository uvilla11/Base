import SwiftUI
import Foundation

@Observable
final class UnitConverterVM {
    var selectedCategory: UnitCategory {
        didSet { UserDefaults.standard.set(selectedCategory.rawValue, forKey: "base.convert.category") }
    }
    var fromValue = "1"
    var toValue = ""
    var fromUnit: String
    var toUnit: String

    init() {
        let saved = UserDefaults.standard.string(forKey: "base.convert.category")
        let category = saved.flatMap(UnitCategory.init(rawValue:)) ?? .length
        selectedCategory = category
        let units = UnitConversion.units(for: category)
        fromUnit = units.first ?? ""
        toUnit = units.count > 1 ? units[1] : units.first ?? ""
        convert()
    }

    func convert() {
        let cleaned = fromValue.replacingOccurrences(of: ",", with: "")
        guard let value = Double(cleaned) else {
            toValue = ""
            return
        }
        let result = UnitConversion.convert(
            value: value,
            from: fromUnit,
            to: toUnit,
            category: selectedCategory
        )
        toValue = Format.pretty(result)
    }

    func swapUnits() {
        swap(&fromUnit, &toUnit)
        convert()
    }

    func categoryChanged() {
        let units = UnitConversion.units(for: selectedCategory)
        fromUnit = units.first ?? ""
        toUnit = units.count > 1 ? units[1] : units.first ?? ""
        convert()
    }
}
