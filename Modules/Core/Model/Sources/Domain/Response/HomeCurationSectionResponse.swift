import Foundation

public struct HomeCurationSectionResponse: Decodable {
    public let items: [HomeCurationItem]
    public let impressionLog: SDImpressionLog?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([LossyHomeCurationItem].self, forKey: .items).compactMap(\.item)
        self.impressionLog = try container.decodeIfPresent(SDImpressionLog.self, forKey: .impressionLog)
    }

    private enum CodingKeys: String, CodingKey {
        case items
        case impressionLog
    }
}
