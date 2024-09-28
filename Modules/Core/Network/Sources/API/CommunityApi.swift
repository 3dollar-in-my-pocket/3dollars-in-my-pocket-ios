import Foundation

import Model

enum CommunityApi {
    case fetchPopularStores(input: FetchPopularStoresInput)
    case fetchPopularStoreNeighborhoods
    case fetchPollReportReasons(type: FetchPollReportReasonsGroupType)
    case reportPoll(pollId: String, input: PollReportCreateRequestInput)
    case fetchPolls(input: FetchPollsRequestInput)
    case fetchMyPolls(input: CursorRequestInput)
    case createChoicePoll(pollId: String, input: PollChoiceCreateRequestInput)
    case fetchPoll(pollId: String)
    case fetchUserPollPolicy
    case fetchPollComments(pollId: String, input: CursorRequestInput)
    case createPollComment(pollId: String, input: CreatePollCommentRequestInput)
    case createPoll(input: PollCreateRequestInput)
    case fetchPollComment(pollId: String, commentId: String)
    case deletePollComment(pollId: String, commentId: String)
    case reportComment(pollId: String, commentId: String, input: PollCommentReportCreateRequestInput)
    case fetchPollCategories
    case toggleReviewSticker(pollId: String, commentId: String, input: PollCommentStickerListInput)
}

extension CommunityApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchPopularStores(let input):
            return input
        case .fetchPopularStoreNeighborhoods:
            return nil
        case .fetchPollReportReasons:
            return nil
        case .reportPoll(_, let input):
            return input
        case .fetchPolls(let input):
            return input
        case .fetchMyPolls(let input):
            return input
        case .createChoicePoll(_, let input):
            return input
        case .fetchPoll:
            return nil
        case .fetchUserPollPolicy:
            return nil
        case .fetchPollComments(_, let input):
            return input
        case .createPollComment(_, let input):
            return input
        case .createPoll(let input):
            return input
        case .fetchPollComment:
            return nil
        case .deletePollComment:
            return nil
        case .reportComment(_, _, let input):
            return input
        case .fetchPollCategories:
            return nil
        case .toggleReviewSticker(_, _, let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchPopularStores:
            return .get
        case .fetchPopularStoreNeighborhoods:
            return .get
        case .fetchPollReportReasons:
            return .get
        case .reportPoll:
            return .post
        case .fetchPolls:
            return .get
        case .fetchMyPolls:
            return .get
        case .createChoicePoll:
            return .put
        case .fetchPoll:
            return .get
        case .fetchUserPollPolicy:
            return .get
        case .fetchPollComments:
            return .get
        case .createPollComment:
            return .post
        case .createPoll:
            return .post
        case .fetchPollComment:
            return .get
        case .deletePollComment:
            return .delete
        case .reportComment:
            return .post
        case .fetchPollCategories:
            return .get
        case .toggleReviewSticker:
            return .put
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchPopularStores:
            return .json
        case .fetchPopularStoreNeighborhoods:
            return .json
        case .fetchPollReportReasons(let type):
            return .json
        case .reportPoll:
            return .auth
        case .fetchPolls:
            return .auth
        case .fetchMyPolls:
            return .auth
        case .createChoicePoll:
            return .auth
        case .fetchPoll:
            return .auth
        case .fetchUserPollPolicy:
            return .auth
        case .fetchPollComments:
            return .auth
        case .createPollComment:
            return .auth
        case .createPoll:
            return .auth
        case .fetchPollComment:
            return .auth
        case .deletePollComment:
            return .auth
        case .reportComment:
            return .auth
        case .fetchPollCategories:
            return .json
        case .toggleReviewSticker:
            return .auth
        }
    }
    
    var path: String {
        switch self {
        case .fetchPopularStores:
            return "/api/v1/neighborhood/popular-stores"
        case .fetchPopularStoreNeighborhoods:
            return "/api/v1/neighborhood/popular-store/neighborhoods"
        case .fetchPollReportReasons(let type):
            return "/api/v1/report/group/\(type.rawValue)/reasons"
        case .reportPoll(let pollId, _):
            return "/api/v1/poll/\(pollId)/report"
        case .fetchPolls:
            return "/api/v1/polls"
        case .fetchMyPolls:
            return "/api/v1/my/polls"
        case .createChoicePoll(let pollId, _):
            return "/api/v1/poll/\(pollId)/choice"
        case .fetchPoll(let pollId):
            return "/api/v1/poll/\(pollId)"
        case .fetchUserPollPolicy:
            return "/api/v1/user/poll/policy"
        case .fetchPollComments(let pollId, _):
            return "/api/v1/poll/\(pollId)/comments"
        case .createPollComment(let pollId, _):
            return "/api/v1/poll/\(pollId)/comment"
        case .createPoll:
            return "/api/v1/poll"
        case .fetchPollComment(let pollId, let commentId):
            return "/api/v1/poll/\(pollId)/comment/\(commentId)"
        case .deletePollComment(let pollId, let commentId):
            return "/api/v1/poll/\(pollId)/comment/\(commentId)"
        case .reportComment(let pollId, let commentId, _):
            return "/api/v1/poll/\(pollId)/comment/\(commentId)/report"
        case .fetchPollCategories:
            return "/api/v1/poll-categories"
        case .toggleReviewSticker(let pollId, let commentId, _):
            return "/api/v1/poll/\(pollId)/comment/\(commentId)/stickers"
        }
    }
}
