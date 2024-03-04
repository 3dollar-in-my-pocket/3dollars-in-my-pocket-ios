import Foundation

public struct Medal: Hashable {
    public let acquisition: Acquisition
    public let disableUrl: String?
    public let iconUrl: String?
    public let introduction: String?
    public let medalId: Int?
    public let name: String
    public var isOwned: Bool
    public var isCurrentMedal: Bool
    
    public init() {
        self.acquisition = Acquisition()
        self.disableUrl = ""
        self.iconUrl = ""
        self.introduction = ""
        self.medalId = -1
        self.name = ""
        self.isOwned = false
        self.isCurrentMedal = false
    }
    
    public init(response: MedalResponse) {
        self.acquisition = Acquisition(response: response.acquisition)
        self.disableUrl = response.disableIconUrl
        self.iconUrl = response.iconUrl
        self.introduction = response.introduction
        self.medalId = response.medalId
        self.name = response.name
        self.isOwned = false
        self.isCurrentMedal = false
    }
    
    public init(response: MedalResponse, isOwned: Bool, isCurrentMedal: Bool) {
        self.acquisition = Acquisition(response: response.acquisition)
        self.disableUrl = response.disableIconUrl
        self.iconUrl = response.iconUrl
        self.introduction = response.introduction
        self.medalId = response.medalId
        self.name = response.name
        self.isOwned = isOwned
        self.isCurrentMedal = isCurrentMedal
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.medalId == rhs.medalId
        && lhs.isOwned == rhs.isOwned
        && lhs.isCurrentMedal == rhs.isCurrentMedal
    }
}

public extension Medal {
    struct Acquisition: Hashable {
        public let description: String?
        
        public init() {
            self.description = ""
        }
        
        public init(response: MedalResponse.MedalAcquisitionResponse?) {
            self.description = response?.description
        }
    }
}
