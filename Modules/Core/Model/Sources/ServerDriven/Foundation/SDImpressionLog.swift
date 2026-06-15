import Foundation

public struct SDImpressionLog: Decodable, Equatable, Hashable {
    public let screenName: String
    public let objectType: String
    public let objectId: String
    public let extraParameters: [String: SDClickLogValue]

    public init(
        screenName: String,
        objectType: String,
        objectId: String,
        extraParameters: [String: SDClickLogValue] = [:]
    ) {
        self.screenName = screenName
        self.objectType = objectType
        self.objectId = objectId
        self.extraParameters = extraParameters
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.screenName = try container.decode(String.self, forKey: .screenName)
        self.objectType = try container.decode(String.self, forKey: .objectType)
        self.objectId = try container.decode(String.self, forKey: .objectId)
        self.extraParameters = try container.decodeIfPresent(
            [String: SDClickLogValue].self,
            forKey: .extraParameters
        ) ?? [:]
    }

    private enum CodingKeys: String, CodingKey {
        case screenName
        case objectType
        case objectId
        case extraParameters
    }
}
