import Foundation
import os

private let httpLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HttpClient", category: "Networking")

/// A simple console logger for HttpClient errors.
final class ConsoleErrorHandler: HttpClientErrorHandlerInterface {
    func handle(error: Error) {
        switch error {
        case let e as HttpClientExceptionDecodeFormat:
            httpLogger.error("DecodeFormatError: message=\(e.message, privacy: .public) source=\(e.source, privacy: .private(mask: .hash)) offset=\(String(describing: e.offset), privacy: .public)")
        case let e as HttpClientExceptionTypeError:
            httpLogger.error("TypeError: message=\(e.message, privacy: .public) stack=\(String(describing: e.stackTrace), privacy: .private(mask: .hash))")
        case let e as HttpClientExceptionClientError:
            httpLogger.warning("ClientError: status=\(e.httpStatusCode)")
        case let e as HttpClientExceptionServerError:
            httpLogger.critical("ServerError: status=\(e.httpStatusCode)")
        case is HttpClientExceptionUndefined:
            httpLogger.warning("Undefined HttpClient error: \(String(describing: error), privacy: .public)")
        default:
            httpLogger.warning("Unknown error passed to HttpClient errorHandler: \(String(describing: error), privacy: .public)")
        }
    }
}

/// Convenience helper to install the console handler at app start.
/// Call this from AppDelegate/SceneDelegate or @main App init.
enum HttpClientErrorHandling {
    static func installConsoleHandler() {
        HttpClient.errorHandler = ConsoleErrorHandler()
        httpLogger.info("HttpClient ConsoleErrorHandler installed")
    }
}
