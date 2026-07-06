import Foundation

enum UnitCategory: String, CaseIterable, Identifiable {
    case length, mass, volume, temperature, currency

    var id: String { rawValue }

    var name: String {
        switch self {
        case .length: return "Length"
        case .mass: return "Mass"
        case .volume: return "Volume"
        case .temperature: return "Temperature"
        case .currency: return "Currency"
        }
    }
}

struct UnitKey: Hashable {
    let category: UnitCategory
    let name: String
}

struct UnitConversion {
    typealias ConversionEntry = (name: String, toSI: Double, fromSI: Double)

    static let tables: [UnitCategory: [ConversionEntry]] = [
        .length: [
            ("m", 1.0, 1.0),
            ("km", 1000.0, 0.001),
            ("mi", 1609.344, 0.000621371),
            ("ft", 0.3048, 3.28084),
            ("in", 0.0254, 39.3701),
            ("cm", 0.01, 100.0),
            ("mm", 0.001, 1000.0),
            ("yd", 0.9144, 1.09361),
        ],
        .mass: [
            ("kg", 1.0, 1.0),
            ("g", 0.001, 1000.0),
            ("mg", 0.000001, 1_000_000.0),
            ("lb", 0.453592, 2.20462),
            ("oz", 0.0283495, 35.274),
            ("st", 6.35029, 0.157473),
        ],
        .volume: [
            ("L", 1.0, 1.0),
            ("mL", 0.001, 1000.0),
            ("gal", 3.78541, 0.264172),
            ("qt", 0.946353, 1.05669),
            ("pt", 0.473176, 2.11338),
            ("cup", 0.236588, 4.22675),
            ("fl oz", 0.0295735, 33.814),
            ("tbsp", 0.0147868, 67.628),
            ("tsp", 0.00492892, 202.884),
        ],
        .temperature: [
            ("°C", 1.0, 1.0),
            ("°F", 1.0, 1.0),
            ("K", 1.0, 1.0),
        ],
        .currency: [
            ("USD", 1.0, 1.0),
            ("EUR", 0.92, 1.087),
            ("GBP", 0.79, 1.266),
            ("JPY", 149.0, 0.00671),
            ("CAD", 1.36, 0.735),
            ("AUD", 1.50, 0.667),
            ("CHF", 0.88, 1.136),
            ("CNY", 7.24, 0.138),
            ("INR", 83.0, 0.0120),
            ("MXN", 17.50, 0.0571),
            ("BRL", 5.05, 0.198),
        ],
    ]

    static func convert(value: Double, from: String, to: String, category: UnitCategory) -> Double {
        guard category != .temperature else {
            return convertTemperature(value: value, from: from, to: to)
        }

        guard let entries = tables[category],
              let fromEntry = entries.first(where: { $0.name == from }),
              let toEntry = entries.first(where: { $0.name == to })
        else { return value }

        let siValue = value * fromEntry.toSI
        return siValue * toEntry.fromSI
    }

    static func convertTemperature(value: Double, from: String, to: String) -> Double {
        var celsius: Double
        switch from {
        case "°C": celsius = value
        case "°F": celsius = (value - 32) * 5 / 9
        case "K": celsius = value - 273.15
        default: return value
        }

        switch to {
        case "°C": return celsius
        case "°F": return celsius * 9 / 5 + 32
        case "K": return celsius + 273.15
        default: return value
        }
    }

    static func units(for category: UnitCategory) -> [String] {
        tables[category]?.map(\.name) ?? []
    }
}
