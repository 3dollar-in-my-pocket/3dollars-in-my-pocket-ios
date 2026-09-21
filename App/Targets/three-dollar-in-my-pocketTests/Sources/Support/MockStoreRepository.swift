import Foundation

import Model
import Networking

/// StoreRepository 목. 필요한 메서드만 `xxxResult`로 스텁하고, 나머지는 `.failure(MockError.notStubbed)`를 돌려준다.
/// 새 메서드를 스텁해야 하면 같은 패턴으로 `var xxxResult` 프로퍼티를 추가한다.
final class MockStoreRepository: StoreRepository {
    var fetchStoreScreenV2Result: Result<StoreScreenV2Response, Error> = .failure(MockError.notStubbed())

    init(fetchStoreScreenV2Result: Result<StoreScreenV2Response, Error>? = nil) {
        if let fetchStoreScreenV2Result {
            self.fetchStoreScreenV2Result = fetchStoreScreenV2Result
        }
    }

    func fetchStoreScreenV2(input: FetchStoreScreenInput) async -> Result<StoreScreenV2Response, Error> { fetchStoreScreenV2Result }
    func createStore(input: UserStoreCreateRequestV3, nonceToken: String) async -> Result<UserStoreResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchAroundStores(input: FetchAroundStoreInput) async -> Result<ContentsWithCursorResponse<StoreWithExtraResponse>, Error> { .failure(MockError.notStubbed()) }
    func fetchStoreDetail(input: FetchStoreDetailInput) async -> Result<UserStoreDetailResponse, Error> { .failure(MockError.notStubbed()) }
    func saveStore(storeId: String, isDelete: Bool) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func reportStore(storeId: Int, reportReason: String) async -> Result<StoreDeleteResponse, Error> { .failure(MockError.notStubbed()) }
    func writeReview(input: WriteReviewRequestInput) async -> Result<StoreReviewWithWriterResponse, Error> { .failure(MockError.notStubbed()) }
    func uploadPhotos(storeId: Int, photos: [Data]) async -> Result<[StoreImageResponse], Error> { .failure(MockError.notStubbed()) }
    func fetchStorePhotos(storeId: Int, cursor: String?) async -> Result<ContentsWithCursorResponse<StoreImageWithApiResponse>, Error> { .failure(MockError.notStubbed()) }
    func editReview(reviewId: Int, input: EditReviewRequestInput) async -> Result<StoreReviewResponse, Error> { .failure(MockError.notStubbed()) }
    func deletePhoto(photoId: Int) async -> Result<String?, Error> { .failure(MockError.notStubbed()) }
    func fetchNewPosts(storeId: String, cursor: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PostWithStoreResponse>, Error> { .failure(MockError.notStubbed()) }
    func togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func existsFeedbackOnDateByAccount(storeId: Int) async -> Result<FeedbackExistsResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchStore(input: FetchStoreInput) async -> Result<StoreDetailResponse, Error> { .failure(MockError.notStubbed()) }
    func patchStore(storeId: String, input: UserStorePatchRequestV3) async -> Result<UserStoreResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchDisplayItems(storeId: Int, itemTypes: [StoreDisplayItemType]) async -> Result<ContentListStoreDisplayResponse, Error> { .failure(MockError.notStubbed()) }
    func recordDisplayItemImpression(storeId: Int, itemTypes: [StoreDisplayItemType]) async -> Result<String?, Error> { .failure(MockError.notStubbed()) }
    func fetchStorePreview(input: FetchStoreScreenInput) async -> Result<StorePreviewScreenResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchStoreContributorHistories(storeId: Int, cursor: String?) async -> Result<StoreContributorHistoriesSection, Error> { .failure(MockError.notStubbed()) }
}
