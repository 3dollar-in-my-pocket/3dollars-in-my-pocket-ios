import Foundation

public struct FetchHomeCardInput: Encodable {
    public let distanceM: Double
    public let categoryIds: [String]?
    public let targetStores: [StoreType]?
    public let size: Int
    public let cursor: String?
    public let mapLatitude: Double
    public let mapLongitude: Double
    public let dynamicParams: [String: String]

    public init(
        distanceM: Double,
        categoryIds: [String]? = nil,
        targetStores: [StoreType] = [.userStore, .bossStore],
        size: Int = 10,
        cursor: String? = nil,
        mapLatitude: Double,
        mapLongitude: Double,
        dynamicParams: [String: String] = [:]
    ) {
        self.distanceM = distanceM
        self.categoryIds = categoryIds
        self.targetStores = targetStores
        self.size = size
        self.cursor = cursor
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
        self.dynamicParams = dynamicParams
    }

    private struct DynamicCodingKey: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) { nil }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        try container.encode(distanceM, forKey: DynamicCodingKey(stringValue: "distanceM"))
        try container.encodeIfPresent(categoryIds, forKey: DynamicCodingKey(stringValue: "categoryIds"))
        try container.encodeIfPresent(targetStores, forKey: DynamicCodingKey(stringValue: "targetStores"))
        try container.encode(size, forKey: DynamicCodingKey(stringValue: "size"))
        try container.encodeIfPresent(cursor, forKey: DynamicCodingKey(stringValue: "cursor"))
        try container.encode(mapLatitude, forKey: DynamicCodingKey(stringValue: "mapLatitude"))
        try container.encode(mapLongitude, forKey: DynamicCodingKey(stringValue: "mapLongitude"))

        for (key, value) in dynamicParams {
            try container.encode(value, forKey: DynamicCodingKey(stringValue: key))
        }
    }
}
