public struct ResponseContainer<T: Decodable>: Decodable {
    public let data: T?
    public let message: String
    public let resultCode: String
}
