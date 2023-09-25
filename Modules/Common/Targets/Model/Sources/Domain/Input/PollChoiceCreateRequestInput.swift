import Foundation

public struct PollChoiceCreateRequestInput: Encodable {
    public let options: [OptionRequestInput]

    public init(options: [OptionRequestInput]) {
        self.options = options
    }
}

public extension PollChoiceCreateRequestInput {
    struct OptionRequestInput: Encodable {
        public let optionId: String

        public init(optionId: String) {
            self.optionId = optionId
        }
    }
}
