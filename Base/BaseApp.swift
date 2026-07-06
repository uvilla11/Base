import SwiftUI

@main
struct BaseApp: App {
    @State private var calculatorVM = CalculatorVM()
    @State private var converterVM = UnitConverterVM()
    @State private var storeTip = StoreTip()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(calculatorVM)
                .environment(converterVM)
                .environment(storeTip)
                .tint(Color.accentColor)
        }
    }
}
