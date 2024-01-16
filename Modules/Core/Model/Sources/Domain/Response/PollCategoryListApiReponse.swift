public struct PollCategoryListApiReponse: Decodable {
    public let categories: [PollCategoryResponse]
}

public struct PollCategoryResponse: Decodable {
    public let categoryId: String
    public let title: String
    public let content: String
}
