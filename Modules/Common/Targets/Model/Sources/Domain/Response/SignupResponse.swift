import Foundation

public struct SignupResponse: Decodable {
    public let token: String
    public let userId: Int
}
