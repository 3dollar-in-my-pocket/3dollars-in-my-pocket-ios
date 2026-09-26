import Foundation

import Model
import Networking

final class MockCommunityRepository: CommunityRepository {
    var fetchPopularStoresResult: Result<ContentsWithCursorResponse<StoreResponse>, Error> = .failure(MockError.notStubbed())

    func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResponse<StoreResponse>, Error> { fetchPopularStoresResult }
    func fetchPopularStoreNeighborhoods() async -> Result<NeighborhoodsResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchPollReportReasons(type: FetchPollReportReasonsGroupType) async -> Result<PollReportReasonResponse, Error> { .failure(MockError.notStubbed()) }
    func reportPoll(pollId: String, input: PollReportCreateRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func fetchPolls(input: FetchPollsRequestInput) async -> Result<ContentsWithCursorResponse<PollWithMetaApiResponse>, Error> { .failure(MockError.notStubbed()) }
    func fetchMyPolls(input: CursorRequestInput) async -> Result<PollListWithUserPollMetaApiResponse, Error> { .failure(MockError.notStubbed()) }
    func createChoicePoll(pollId: String, input: PollChoiceCreateRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func fetchPoll(pollId: String) async -> Result<PollWithMetaApiResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchUserPollPolicy() async -> Result<PollPolicyApiResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchPollComments(pollId: String, input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PollCommentWithUserRecursiveApiResponse>, Error> { .failure(MockError.notStubbed()) }
    func createPollComment(pollId: String, input: CreatePollCommentRequestInput) async -> Result<IdResponseString, Error> { .failure(MockError.notStubbed()) }
    func createPoll(input: PollCreateRequestInput) async -> Result<IdResponseString, Error> { .failure(MockError.notStubbed()) }
    func fetchPollComment(pollId: String, commentId: String) async -> Result<PollCommentWithUserRecursiveApiResponse, Error> { .failure(MockError.notStubbed()) }
    func deletePollComment(pollId: String, commentId: String) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func reportComment(pollId: String, commentId: String, input: PollCommentReportCreateRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func fetchPollCategories() async -> Result<PollCategoryListApiReponse, Error> { .failure(MockError.notStubbed()) }
    func toggleReviewSticker(pollId: String, commentId: String, input: PollCommentStickerListInput) async -> Result<String?, Error> { .failure(MockError.notStubbed()) }
}
