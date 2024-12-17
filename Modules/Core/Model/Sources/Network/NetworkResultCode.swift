import Foundation

public enum NetworkResultCode: String {
    case unauthorized = "UA000"
    case serviceUnavailable = "SU000"
    case forbidden = "FB000"
    case unknown
    
    public init(value: String?) {
        guard let value else {
            self = .unknown
            return
        }
        self = NetworkResultCode(rawValue: value) ?? .unknown
    }
}
