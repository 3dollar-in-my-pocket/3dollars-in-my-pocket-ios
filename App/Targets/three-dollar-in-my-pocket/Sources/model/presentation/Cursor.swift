struct Cursor {
    let hasMore: Bool
    let nextCursor: String?
    let totalCount: Int
    
    init(response: CursorWithTotalCountResponse) {
        self.hasMore = response.hasMore
        self.nextCursor = response.nextCursor
        self.totalCount = response.totalCount
    }
}
