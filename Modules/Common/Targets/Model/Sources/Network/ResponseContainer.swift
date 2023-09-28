public struct ResponseContainer<T: Decodable>: Decodable {
    public let data: T?
    public let error: String?
    public let resultCode: String?
}
