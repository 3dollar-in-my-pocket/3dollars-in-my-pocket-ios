struct ResponseContainer<T: Decodable>: Decodable {
    let data: T?
    let message: String
    let resultCode: String
}
