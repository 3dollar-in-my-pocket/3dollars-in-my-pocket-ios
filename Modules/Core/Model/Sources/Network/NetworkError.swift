public enum NetworkError: Error {
    case decodingError
    case timeoutError
    case noData
    case message(String)
    case unknown
    case invalidURL
    case errorContainer(ErrorContainer)
}

public struct ErrorContainer {
    public let message: String?
    public let resultCode: String?
    
    public init(message: String?, resultCode: String?) {
        self.message = message
        self.resultCode = resultCode
    }
}
