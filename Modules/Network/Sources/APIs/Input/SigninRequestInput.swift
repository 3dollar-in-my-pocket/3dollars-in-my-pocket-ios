import Foundation

public struct SigninRequestInput: Encodable {
    let socialType: String
    let token: String
    
    public init(socialType: String, token: String) {
        self.socialType = socialType
        self.token = token
    }
}
