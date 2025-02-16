import Foundation

public struct StoreReviewWithWriterResponse: Decodable {
    public let review: StoreReviewResponse
    public let reviewWriter: UserResponse
    public let reviewReport: ReportResponse
    public let stickers: [StickerResponse]
    public let comments: ContentListCommentResponse
}
