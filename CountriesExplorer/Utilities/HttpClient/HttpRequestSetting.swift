import Foundation

protocol HttpRequestSetting {
  associatedtype Output: Decodable
  var endpoint: HttpRequestEndpoint { get }
  var method: HttpRequestMethod { get }
  func parameters() async -> [String: Any]
  func headers() async -> [String: String]
  func decode(_ data: Data) throws -> Output
}

extension HttpRequestSetting {
  func decode(_ data: Data) throws -> Output {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(Output.self, from: data)
  }
}
