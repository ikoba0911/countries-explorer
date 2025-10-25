import SwiftUI
import ComposableArchitecture

@main
struct CountriesExplorerApp: App {
    init() {
        // Install HttpClient console error handler at app launch
        HttpClientErrorHandling.installConsoleHandler()
    }

    var body: some Scene {
        WindowGroup {
            CountryListView(
                store: Store(initialState: CountryListFeature.State()) {
                    CountryListFeature()
                }
            )
        }
    }
}

