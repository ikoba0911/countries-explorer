import Foundation

struct HttpSessionResponse {
  let code: Int
  let headers: [AnyHashable: Any]
  let data: Data
}

struct HttpSessionSetting {
  static let `default` = HttpSessionSetting()
  let session: URLSession = .shared
  let timeout: TimeInterval = 20

  func request(
    url: URL,
    method: HttpSessionMethod,
    headers: [String: String],
    parameters: [String: Any]
  ) async throws -> HttpSessionResponse {

    func encodeQuery(_ parameters: [String: Any]) -> String {
      // Support key[]=v for array values, like Dart implementation
      parameters.map { key, value in
        if let array = value as? [Any] {
          return array.map { element in
            let v = String(describing: element)
            return "\(key)[]=" + (v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? v)
          }.joined(separator: "&")
        } else {
          let v = String(describing: value)
          return "\(key)=" + (v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? v)
        }
      }.joined(separator: "&")
    }

    var requestURL = url
    var urlRequest = URLRequest(url: url)
    urlRequest.timeoutInterval = timeout

    // Apply headers
    headers.forEach { k, v in urlRequest.setValue(v, forHTTPHeaderField: k) }

    switch method {
    case .get, .delete:
      // Append encoded parameters as query
      if parameters.isEmpty == false, var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
        let existing = comps.percentEncodedQuery.map { $0 + "&" } ?? ""
        comps.percentEncodedQuery = existing + encodeQuery(parameters)
        if let newURL = comps.url { requestURL = newURL }
      }
      urlRequest.url = requestURL
    case .post, .put, .patch:
      // JSON body
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    }

    // HTTP method
    switch method {
    case .get: urlRequest.httpMethod = "GET"
    case .post: urlRequest.httpMethod = "POST"
    case .patch: urlRequest.httpMethod = "PATCH"
    case .put: urlRequest.httpMethod = "PUT"
    case .delete: urlRequest.httpMethod = "DELETE"
    }

    let (data, response) = try await session.data(for: urlRequest)
    guard let http = response as? HTTPURLResponse else {
      return HttpSessionResponse(code: -1, headers: [:], data: data)
    }
    return HttpSessionResponse(code: http.statusCode, headers: http.allHeaderFields, data: data)
  }
}
