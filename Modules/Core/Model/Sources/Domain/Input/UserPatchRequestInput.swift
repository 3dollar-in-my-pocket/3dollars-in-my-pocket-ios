import Foundation

public struct UserPatchRequestInput: Encodable {
    public let name: String?
    public let representativeMedalId: Int?
    public let gender: Gender?
    public let birth: UserBirthRequest?
    
    public init(
        name: String? = nil,
        representativeMedalId: Int? = nil,
        gender: Gender? = nil,
        birth: UserBirthRequest? = nil
    ) {
        self.name = name
        self.representativeMedalId = representativeMedalId
        self.gender = gender
        self.birth = birth
    }
}

public enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
}

public struct UserBirthRequest: Encodable {
    public let year: Int
    
    public init(year: Int) {
        self.year = year
    }
}
