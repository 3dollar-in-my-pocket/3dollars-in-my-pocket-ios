import Foundation

struct AdvertisementResponse: Decodable {
    let advertisementId: Int
    let title: String
    let subTitle: String
    let extraContent: String?
    let imageUrl: String
    let imageWidth: Int
    let imageHeight: Int
    let linkUrl: String
    let bgColor: String
    let fontColor: String
}
