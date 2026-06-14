import Foundation

public struct SDPageViewLog: Decodable, Equatable, Hashable {
    public let screenName: String
    public let extraParameters: [String: String]

    public init(screenName: String, extraParameters: [String: String] = [:]) {
        self.screenName = screenName
        self.extraParameters = extraParameters
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.screenName = try container.decode(String.self, forKey: .screenName)
        self.extraParameters = try container.decodeIfPresent([String: String].self, forKey: .extraParameters) ?? [:]
    }

    private enum CodingKeys: String, CodingKey {
        case screenName
        case extraParameters
    }
}
