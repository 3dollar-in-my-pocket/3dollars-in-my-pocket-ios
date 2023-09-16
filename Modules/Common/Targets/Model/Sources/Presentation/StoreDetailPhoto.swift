import Foundation

public struct StoreDetailPhoto: Hashable {
    public let imageId: Int
    public let url: String
    public let totalCount: Int
    
    public init(response: StoreImageApiResponse, totalCount: Int) {
        self.imageId = response.imageId
        self.url = response.url
        self.totalCount = totalCount
    }
}
