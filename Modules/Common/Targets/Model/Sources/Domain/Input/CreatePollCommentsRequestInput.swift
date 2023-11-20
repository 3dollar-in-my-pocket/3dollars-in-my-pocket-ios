import Foundation

public struct CreatePollCommentRequestInput: Encodable {
    public let content: String

    public init(content: String) {
        self.content = content
    }
}
