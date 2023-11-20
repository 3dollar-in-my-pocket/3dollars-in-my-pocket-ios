import Foundation

public struct StoreOpenResponse: Decodable {
    public let status: StoreOpenStatus
    public let openStartDateTime: String?

    public enum StoreOpenStatus: String, Decodable {
        case open = "OPEN"
        case closed = "CLOSED"
    }
}
