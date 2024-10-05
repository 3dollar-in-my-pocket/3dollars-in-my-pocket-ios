public enum HTTPHeaderType {
    case json
    case multipart(boundary: String)
    case location
    case custom([String: String])
}
