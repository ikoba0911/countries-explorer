enum HttpRequestMethod { case get, post, patch, put, delete }

enum HttpSessionMethod { case get, post, patch, put, delete }

extension HttpRequestMethod {
  var toSession: HttpSessionMethod {
    switch self {
    case .get: return .get
    case .post: return .post
    case .patch: return .patch
    case .put: return .put
    case .delete: return .delete
    }
  }
}
