import Foundation

public struct Medal: Hashable {
    public let medalId: Int?
    public let name: String
    public let iconUrl: String?
    public let disableIconUrl: String?
    public let introduction: String?
    
    public init(response: MedalResponse) {
        self.medalId = response.medalId
        self.name = response.name
        self.iconUrl = response.iconUrl
        self.disableIconUrl = response.disableIconUrl
        self.introduction = response.introduction
    }
}
