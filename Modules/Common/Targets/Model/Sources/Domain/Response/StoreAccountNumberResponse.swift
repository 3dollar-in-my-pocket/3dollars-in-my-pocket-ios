import Foundation

public struct StoreAccountNumberResponse: Decodable {
    public let bank: BankResponse
    public let accountHolder: String
    public let accountNumber: String
    public let description: String
}
