public enum NetworkError: Error {
    case decodingError
    case timeoutError
    case noData
    case message(String)
    case unknown
    case invalidURL
}
