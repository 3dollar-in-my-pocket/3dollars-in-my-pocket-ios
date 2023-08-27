import Foundation

public struct SigninRequestInput: Encodable {
    public let socialType: String
    public let token: String
    
    public init(socialType: String, token: String) {
        self.socialType = socialType
        self.token = token
    }
}
