import Foundation

final class HttpClient {
  static var errorHandler: HttpClientErrorHandlerInterface?

  private let session: HttpSessionSetting

  init(session: HttpSessionSetting = .default) {
    self.session = session
  }

  func request<S: HttpRequestSetting>(_ setting: S) async throws -> S.Output {
    guard let url = setting.endpoint.url else {
        throw HttpClientError.invalidURL
    }

    let headers = await setting.headers()
    let parameters = await setting.parameters()

    let response = try await session.request(
      url: url,
      method: setting.method.toSession,
      headers: headers,
      parameters: parameters
    )

    // Success path
    if (200..<300).contains(response.code) {
      do {
        return try setting.decode(response.data)
      } catch let decoding as DecodingError {
        let message: String
        switch decoding {
        case .typeMismatch(let type, let ctx):
          message = "Type mismatch for \(type): \(ctx.debugDescription)"
        case .valueNotFound(let type, let ctx):
          message = "Value not found for \(type): \(ctx.debugDescription)"
        case .keyNotFound(let key, let ctx):
          message = "Key not found: \(key.stringValue) - \(ctx.debugDescription)"
        case .dataCorrupted(let ctx):
          message = "Data corrupted: \(ctx.debugDescription)"
        @unknown default:
          message = "Unknown decoding error"
        }
        let error = HttpClientExceptionDecodeFormat(
          source: String(data: response.data, encoding: .utf8) ?? "<non-utf8>",
          message: message,
          offset: nil
        )
        Self.errorHandler?.handle(error: error)
        throw error
      } catch {
        let error = HttpClientExceptionTypeError(
          message: String(describing: error),
          stackTrace: nil
        )
        Self.errorHandler?.handle(error: error)
        throw error
      }
    }

    // Error mapping
    let mappedError: Error
    if (300..<400).contains(response.code) {
      mappedError = HttpClientExceptionUndefined()
    } else if (400..<500).contains(response.code) {
      mappedError = HttpClientExceptionClientError(httpStatusCode: response.code)
    } else if response.code >= 500 {
      mappedError = HttpClientExceptionServerError(httpStatusCode: response.code)
    } else {
      mappedError = HttpClientExceptionUndefined()
    }

    Self.errorHandler?.handle(error: mappedError)
    throw mappedError
  }
}

