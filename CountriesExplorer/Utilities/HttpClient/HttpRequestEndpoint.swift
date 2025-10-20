import Foundation

struct HttpRequestEndpoint {
  let host: String
  let path: String

  var url: URL? {
    URL(string: host + path)
  }
}
