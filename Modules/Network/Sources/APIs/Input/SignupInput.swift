import Foundation

public struct SignupInput: Encodable {
    let name: String
    let socialType: String
    let token: String
    
    public init(name: String, socialType: String, token: String) {
        self.name = name
        self.socialType = socialType
        self.token = token
    }
}
