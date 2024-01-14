import Foundation

public struct PollCreateRequestInput: Encodable {
    public let categoryId: String
    public let title: String
    public let subTitle: String?
    public let imageUrl: String?
    public let startDateTime: String
    public let endDateTime: String
    public let options: [PollOptionCreateRequestInput]

    public init(categoryId: String = "TASTE_VS_TASTE", title: String, subTitle: String? = nil, imageUrl: String? = nil, startDateTime: String, endDateTime: String, options: [PollOptionCreateRequestInput]) {
        self.categoryId = categoryId
        self.title = title
        self.subTitle = subTitle
        self.imageUrl = imageUrl
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.options = options
    }
}

public struct PollOptionCreateRequestInput: Encodable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
