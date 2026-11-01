import Foundation

public struct ContentListCreatorGroupResponse: Decodable {
    public let contents: [CreatorGroupResponse]

    public init(contents: [CreatorGroupResponse]) {
        self.contents = contents
    }
}

public struct CreatorGroupResponse: Decodable, Equatable {
    public let role: String
    public let creatorNames: [String]

    public init(role: String, creatorNames: [String]) {
        self.role = role
        self.creatorNames = creatorNames
    }
}
