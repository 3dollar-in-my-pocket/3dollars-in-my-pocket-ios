public enum HTTPHeaderType {
    case json
    case multipart(boundary: String)
    case auth
    case location
    case custom([String: String])
}
