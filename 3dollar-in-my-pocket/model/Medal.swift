struct Medal: Equatable {
    let disableUrl: String
    let iconUrl: String
    let medalId: Int
    let name: String
    var isOwned: Bool
    
    init() {
        self.disableUrl = ""
        self.iconUrl = ""
        self.medalId = -1
        self.name = ""
        self.isOwned = false
    }
    
    init(response: MedalResponse) {
        self.disableUrl = response.disableIconUrl
        self.iconUrl = response.iconUrl
        self.medalId = response.medalId
        self.name = response.name
        self.isOwned = false
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.medalId == rhs.medalId
    }
}
