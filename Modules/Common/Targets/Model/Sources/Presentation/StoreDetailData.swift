import Foundation

public struct StoreDetailData {
    public let overview: StoreDetailOverview
    
    public init(response: StoreWithDetailApiResponse) {
        overview = StoreDetailOverview(
            categories: response.store.categories.map { PlatformStoreCategory(response: $0) },
            repoterName: response.creator.name,
            storeName: response.store.name,
            isNew: response.tags.isNew,
            totalVisitSuccessCount: response.visits.counts.existsCounts,
            reviewCount: response.reviews.cursor.totalCount,
            distance: response.distanceM,
            location: Location(response: response.store.location),
            address: response.store.address.fullAddress
        )
    }
}
