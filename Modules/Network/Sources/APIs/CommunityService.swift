import Model

public protocol CommunityServiceProtocol {
    func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResposne<PlatformStoreResponse>, Error>
    /// 동네 인기 가게가 활성화된 동네 목록 조회
    func fetchPopularStoreNeighborhoods() async -> Result<NeighborhoodsResponse, Error>
    /// 투표 신고 이유 목록 조회 (나중에 공용 API 로 통합 필요)
    func fetchPollReportReasons() async -> Result<PollReportReasonResponse, Error>
    /// 투표 신고
    func reportPoll(pollId: String, input: PollReportCreateRequestInput) async -> Result<Bool, Error>
    /// 투표 목록 조회
    func fetchPolls(input: FetchPollsRequestInput) async -> Result<ContentsWithCursorResposne<PollWithMetaApiResponse>, Error>
    // 투표 참여
    func createChoicePoll(pollId: String, input: PollChoiceCreateRequestInput) async -> Result<String, Error>
    /// 투표 단건 조회
    func fetchPoll(pollId: String) async -> Result<PollWithMetaApiResponse, Error>
    /// 유저 투표 정책 조회
    func fetchUserPollPolicy() async -> Result<PollPolicyApiResponse, Error>
}

public struct CommunityService: CommunityServiceProtocol {
    public init() { }

    public func fetchPopularStores(input: FetchPopularStoresInput) async -> Result<ContentsWithCursorResposne<PlatformStoreResponse>, Error> {
        let request = FetchPopularStoresRequest(requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchPopularStoreNeighborhoods() async -> Result<NeighborhoodsResponse, Error> {
        let request = FetchPopularStoreNeighborhoodsRequest()

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchPollReportReasons() async -> Result<PollReportReasonResponse, Error> {
        let request = FetchPollReportReasonRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }

    public func reportPoll(pollId: String, input: PollReportCreateRequestInput) async -> Result<Bool, Error> {
        let request = PollReportCreateRequest(pollId: pollId, requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchPolls(input: FetchPollsRequestInput) async -> Result<ContentsWithCursorResposne<PollWithMetaApiResponse>, Error> {
        let request = FetchPollsRequest(requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func createChoicePoll(pollId: String, input: PollChoiceCreateRequestInput) async -> Result<String, Error> {
        let request = CreateChoicePollRequest(pollId: pollId, requestInput: input)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchPoll(pollId: String) async -> Result<PollWithMetaApiResponse, Error> {
        let request = FetchPollRequest(pollId: pollId)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchUserPollPolicy() async -> Result<PollPolicyApiResponse, Error> {
        let request = FetchPollUserPollPolicyRequest()

        return await NetworkManager.shared.request(requestType: request)
    }
}
