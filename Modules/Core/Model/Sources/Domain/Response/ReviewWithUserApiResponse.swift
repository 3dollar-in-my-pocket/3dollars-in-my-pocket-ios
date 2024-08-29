import Foundation

public struct ReviewWithUserApiResponse: Decodable {
    public let review: ReviewApiResponse
    public let reviewWriter: UserApiResponse
    public let reviewReport: ReviewReportApiResponse
    public let stickers: [StickerResponse]
}
