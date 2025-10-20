import Foundation
import ComposableArchitecture

struct CountryClient {
    var fetchAll: @Sendable () async throws -> [Country]
}

extension CountryClient: DependencyKey {
    static let liveValue: CountryClient = .init(
        fetchAll: {
            let client = await HttpClient()
            let countries = try await client.request(CountryAllRequestSetting())
            return countries.sorted { $0.name.common < $1.name.common }
        }
    )
}

extension DependencyValues {
    var countryClient: CountryClient {
        get { self[CountryClient.self] }
        set { self[CountryClient.self] = newValue }
    }
}
