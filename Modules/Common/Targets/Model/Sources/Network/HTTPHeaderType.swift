public enum HTTPHeaderType {
    case json
    case multipart(boundary: String)
    case auth
    case custom([String: String])
}
