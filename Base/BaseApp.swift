import SwiftUI

@main
struct BaseApp: App {
    @State private var calculatorVM = CalculatorVM()
    @State private var converterVM = UnitConverterVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(calculatorVM)
                .environment(converterVM)
                .tint(Color.accentColor)
        }
    }
}
