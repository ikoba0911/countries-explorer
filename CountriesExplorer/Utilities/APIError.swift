import Foundation

enum APIError: LocalizedError, Equatable {
  case invalidURL
  case requestFailed(Int)
  case decodingFailed
  case unknown

  var errorDescription: String? {
    switch self {
    case .invalidURL: return "Invalid URL"
    case .requestFailed(let code): return "Request failed with status \(code)"
    case .decodingFailed: return "Failed to decode response"
    case .unknown: return "Unknown error"
    }
  }
}
