struct Medal: Equatable {
    let acquisition: Acquisition
    let disableUrl: String
    let iconUrl: String
    let introduction: String
    let medalId: Int
    let name: String
    var isOwned: Bool
    var isCurrentMedal: Bool
    
    init() {
        self.acquisition = Acquisition()
        self.disableUrl = ""
        self.iconUrl = ""
        self.introduction = ""
        self.medalId = -1
        self.name = ""
        self.isOwned = false
        self.isCurrentMedal = false
    }
    
    init(response: MedalResponse) {
        self.acquisition = Acquisition(response: response.acquisition)
        self.disableUrl = response.disableIconUrl
        self.iconUrl = response.iconUrl
        self.introduction = response.introduction
        self.medalId = response.medalId
        self.name = response.name
        self.isOwned = false
        self.isCurrentMedal = false
    }
    
    init(response: UserMedalResponse) {
        self.acquisition = Acquisition()
        self.disableUrl = response.disableIconUrl
        self.iconUrl = response.iconUrl
        self.introduction = ""
        self.medalId = response.medalId
        self.name = response.name
        self.isOwned = false
        self.isCurrentMedal = false
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.medalId == rhs.medalId
        && lhs.isOwned == rhs.isOwned
        && lhs.isCurrentMedal == rhs.isCurrentMedal
    }
}

extension Medal {
    struct Acquisition {
        let description: String
        
        init() {
            self.description = ""
        }
        
        init(response: MedalResponse.MedalAcquisitionResponse) {
            self.description = response.description
        }
    }
}
