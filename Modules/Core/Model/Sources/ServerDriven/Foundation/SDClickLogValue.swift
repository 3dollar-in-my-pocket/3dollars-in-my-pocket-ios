import Foundation

/// `SDClickLog` / `SDImpressionLog` 의 extraParameters 값.
/// 서버는 임의 타입을 보낼 수 있어 (string/int/double/bool/null) 모두 보존한다.
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
