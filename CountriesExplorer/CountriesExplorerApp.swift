import SwiftUI
import ComposableArchitecture

@main
struct CountriesExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            CountryListView(
                store: Store(initialState: CountryListFeature.State()) {
                    CountryListFeature()
                        ._printChanges() // デバッグ用。不要なら削除
                }
            )
        }
    }
}
