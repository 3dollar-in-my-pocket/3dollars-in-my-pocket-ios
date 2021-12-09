struct Medal {
    let iconUrl: String
    let medalId: Int
    let name: String
    
    init() {
        self.iconUrl = ""
        self.medalId = -1
        self.name = ""
    }
    
    init(response: MedalResponse) {
        self.iconUrl = response.iconUrl
        self.medalId = response.medalId
        self.name = response.name
    }
}
