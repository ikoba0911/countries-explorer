import Foundation
import ComposableArchitecture

struct CountryClient {
  var fetchAll: @Sendable () async throws -> [Country]
}

extension CountryClient: DependencyKey {
  static let liveValue: CountryClient = .init(
    fetchAll: {
      guard let url = URL(string:
        "https://restcountries.com/v3.1/all?fields=name,cca3,capital,region,population,flags"
      ) else { throw APIError.invalidURL }

      var request = URLRequest(url: url)
      request.timeoutInterval = 20

      let (data, response) = try await URLSession.shared.data(for: request)
      if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
        throw APIError.requestFailed(http.statusCode)
      }

      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase

      do {
        let countries = try decoder.decode([Country].self, from: data)
        return countries.sorted { $0.name.common < $1.name.common }
      } catch {
        throw APIError.decodingFailed
      }
    }
  )
}

extension DependencyValues {
  var countryClient: CountryClient {
    get { self[CountryClient.self] }
    set { self[CountryClient.self] = newValue }
  }
}
