protocol HttpClientErrorHandlerInterface: AnyObject { func handle(error: Error) }

struct HttpClientExceptionUndefined: Error {}
struct HttpClientExceptionInvalidURL: Error {}

struct HttpClientExceptionDecodeFormat: Error {
  let source: String
  let message: String
  let offset: Int?
}

struct HttpClientExceptionTypeError: Error {
  let message: String
  let stackTrace: String?
}

struct HttpClientExceptionClientError: Error { let httpStatusCode: Int }
struct HttpClientExceptionServerError: Error { let httpStatusCode: Int }

/// A unified, Equatable HTTP client error that can be used in features and reducers
enum HttpClientError: Error, Equatable {
  case undefined
  case invalidURL
  case decodeFormat(source: String, message: String, offset: Int?)
  case typeError(message: String, stackTrace: String?)
  case clientError(code: Int)
  case serverError(code: Int)
  case unknown
}

/// Maps arbitrary Error values produced by the HTTP client into a unified HttpClientError
func mapToHttpClientError(_ error: Error) -> HttpClientError {
  switch error {
  case is HttpClientExceptionUndefined:
    return .undefined
  case is HttpClientExceptionInvalidURL:
    return .invalidURL
  case let e as HttpClientExceptionDecodeFormat:
    return .decodeFormat(source: e.source, message: e.message, offset: e.offset)
  case let e as HttpClientExceptionTypeError:
    return .typeError(message: e.message, stackTrace: e.stackTrace)
  case let e as HttpClientExceptionClientError:
    return .clientError(code: e.httpStatusCode)
  case let e as HttpClientExceptionServerError:
    return .serverError(code: e.httpStatusCode)
  default:
    return .unknown
  }
}
