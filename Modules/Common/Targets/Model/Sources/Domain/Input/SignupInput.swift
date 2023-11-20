import Foundation

public struct SignupInput: Encodable {
    public let name: String
    public let socialType: String
    public let token: String
    
    public init(name: String, socialType: String, token: String) {
        self.name = name
        self.socialType = socialType
        self.token = token
    }
}
