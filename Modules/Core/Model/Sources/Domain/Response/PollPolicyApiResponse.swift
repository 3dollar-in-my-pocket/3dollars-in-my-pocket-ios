import Foundation

public struct PollPolicyApiResponse: Decodable {
    public let createPolicy: PollCreatePolicyApiResponse
}

public struct PollCreatePolicyApiResponse: Decodable {
    public let limitCount: Int
    public let currentCount: Int
    public let pollRetentionDays: Int
}
