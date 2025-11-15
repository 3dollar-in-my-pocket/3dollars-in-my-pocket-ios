import Foundation

public struct ContentListUserNameResponse: Decodable {
    public let contents: [UserNameResponse]
}

public struct UserNameResponse: Decodable {
    public let name: String
}
