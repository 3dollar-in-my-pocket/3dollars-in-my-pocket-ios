import Foundation

/// `/v1/screen/home/section/list` 쿼리 파라미터.
/// 위치 / 페이지네이션 같은 앱 내부 상태에서 결정되는 값만 고정 필드로 받고,
/// SDU 필터(`sortType`, `categoryIds`, `targetStores`, `filterConditions`, `filterCertifiedStores`,
/// `filterOpenStatuses`, `filterMinReviewRating` 등)는 모두 `dynamicParams` 로 흘려보낸다.
/// 배열 파라미터는 `","` 로 join 한 문자열로 전달한다 (NetworkProvider 의 queryItems 가 동일하게 처리).
public struct FetchHomeSectionListInput: Encodable {
    public let distanceM: Double?
    public let cursor: String?
    public let mapLatitude: Double
    public let mapLongitude: Double
    public let dynamicParams: [String: String]

    public init(
        distanceM: Double? = nil,
        cursor: String? = nil,
        mapLatitude: Double,
        mapLongitude: Double,
        dynamicParams: [String: String] = [:]
    ) {
        self.distanceM = distanceM
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
        try container.encodeIfPresent(distanceM, forKey: DynamicCodingKey(stringValue: "distanceM"))
        try container.encodeIfPresent(cursor, forKey: DynamicCodingKey(stringValue: "cursor"))
        try container.encode(mapLatitude, forKey: DynamicCodingKey(stringValue: "mapLatitude"))
        try container.encode(mapLongitude, forKey: DynamicCodingKey(stringValue: "mapLongitude"))

        // 정적 필드와 같은 키가 dynamicParams 에 있으면 정적 필드를 우선시 (중복 쿼리 키 방지).
        let staticKeys: Set<String> = ["distanceM", "cursor", "mapLatitude", "mapLongitude"]
        for (key, value) in dynamicParams where staticKeys.contains(key) == false {
            try container.encode(value, forKey: DynamicCodingKey(stringValue: key))
        }
    }
}
