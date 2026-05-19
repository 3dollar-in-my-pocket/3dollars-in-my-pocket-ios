import Foundation

public struct SDClickLog: Decodable, Equatable, Hashable {
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

/// SDClickLog.extraParameters 의 값. 서버는 임의 타입을 보낼 수 있어 (string/int/double/bool) 모두 보존한다.
public enum SDClickLogValue: Decodable, Equatable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
            return
        }
        // Bool 을 Int 보다 먼저 시도 — JSONDecoder 는 true/false 를 Int 로 디코드하지 않으므로 안전하다.
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self = .int(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .double(value)
            return
        }
        let value = try container.decode(String.self)
        self = .string(value)
    }

    /// GA 파라미터로 직렬화할 때 사용하는 raw 값.
    public var anyValue: Any? {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .bool(let value): return value
        case .null: return nil
        }
    }
}
