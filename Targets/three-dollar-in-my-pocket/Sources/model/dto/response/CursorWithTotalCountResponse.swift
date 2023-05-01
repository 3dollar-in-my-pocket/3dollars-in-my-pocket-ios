struct CursorWithTotalCountResponse: Decodable {
    let hasMore: Bool
    let nextCursor: String?
    let totalCount: Int
}
