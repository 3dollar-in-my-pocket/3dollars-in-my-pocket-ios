import Foundation

public struct StoreAccountNumber {
    public let bank: Bank
    public let accountHolder: String
    public let accountNumber: String
    public let description: String
    
    public init(response: StoreAccountNumberResponse) {
        self.bank = Bank(response: response.bank)
        self.accountHolder = response.accountHolder
        self.accountNumber = response.accountNumber
        self.description = response.description
    }
}
