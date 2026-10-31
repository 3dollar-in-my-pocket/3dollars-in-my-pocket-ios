import Foundation

import Model
import Networking

final class MockMyPageRepository: MyPageRepository {
    var fetchMyStoreVisitsResult: Result<ContentsWithCursorResponse<StoreVisitWithStoreApiResponse>, Error> = .failure(MockError.notStubbed())

    func fetchMyStoreVisits(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<StoreVisitWithStoreApiResponse>, Error> {
        fetchMyStoreVisitsResult
    }

    func fetchMyFavoriteStores(input: CursorRequestInput) async -> Result<StoreFavoriteFolderApiResponse, Error> {
        .failure(MockError.notStubbed())
    }

    func fetchMyStores(input: CursorRequestInput) async -> Result<ContentsWithCursorWithTotalCountResponse<UserStoreWithVisitsResponse>, Error> {
        .failure(MockError.notStubbed())
    }
}
