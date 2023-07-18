import Foundation

public struct AdvertisementResponse: Decodable {
    public let advertisementId: Int
    public let title: String?
    public let subTitle: String?
    public let extraContent: String?
    public let imageUrl: String?
    public let imageWidth: Int
    public let imageHeight: Int
    public let linkUrl: String?
    public let bgColor: String?
    public let fontColor: String?
}
