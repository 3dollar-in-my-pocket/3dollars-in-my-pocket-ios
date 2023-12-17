import Foundation

public struct BossStoreInfo {
    public let updatedAt: String
    public let snsUrl: String?
    public let introduction: String?
    public let imageUrl: String?
    public let accountInfos: [StoreAccountNumber]
    
    public init(
        updatedAt: String,
        snsUrl: String?,
        introduction: String?,
        imageUrl: String?,
        accountInfos: [StoreAccountNumber]
    ) {
        self.updatedAt = updatedAt
        self.snsUrl = snsUrl
        self.introduction = introduction
        self.imageUrl = imageUrl
        self.accountInfos = accountInfos
    }
}
