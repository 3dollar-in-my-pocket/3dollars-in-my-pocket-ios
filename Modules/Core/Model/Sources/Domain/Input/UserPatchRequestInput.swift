import Foundation

public struct UserPatchRequestInput: Encodable {
    public let name: String?
    public let representativeMedalId: Int?
    
    public init(name: String? = nil, representativeMedalId: Int? = nil) {
        self.name = name
        self.representativeMedalId = representativeMedalId
    }
}
