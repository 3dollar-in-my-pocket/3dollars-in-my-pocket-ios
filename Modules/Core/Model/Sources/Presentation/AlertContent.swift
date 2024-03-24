public struct AlertContent: Equatable {
    public let title: String?
    public let message: String?
    
    
    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
    }
}
