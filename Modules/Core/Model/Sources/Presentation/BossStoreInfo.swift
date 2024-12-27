import Foundation

public struct BossStoreInfo {
    public let updatedAt: String
    public let snsUrl: String?
    public let introduction: String?
    public let images: [ImageResponse]
    public let accountInfos: [StoreAccountNumber]
    public let contactsNumbers: [BossStoreContactsNumberResponse]
    
    public init(
        updatedAt: String,
        snsUrl: String?,
        introduction: String?,
        images: [ImageResponse],
        accountInfos: [StoreAccountNumber],
        contactsNumbers: [BossStoreContactsNumberResponse]
    ) {
        self.updatedAt = updatedAt
        self.snsUrl = snsUrl
        self.introduction = introduction
        self.images = images
        self.accountInfos = accountInfos
        self.contactsNumbers = contactsNumbers
    }
}
