import Foundation

public struct StorePreviewScreenResponse: Decodable {
    public let sections: [any StoreSectionComponent]
    public let viewLog: SDPageViewLog

    private enum CodingKeys: String, CodingKey {
        case sections
        case viewLog
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sections = try StoreSectionComponentsDecoder.decode(
            container.nestedUnkeyedContainer(forKey: .sections)
        )
        self.viewLog = try container.decode(SDPageViewLog.self, forKey: .viewLog)
    }

    public var previewSection: StoreScreenPreviewSection? {
        sections.compactMap { $0 as? StoreScreenPreviewSection }.first
    }
}
