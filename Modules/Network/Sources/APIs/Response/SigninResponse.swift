import Foundation

public struct SigninResponse: Decodable {
    public let token: String
    public let userId: Int
}
