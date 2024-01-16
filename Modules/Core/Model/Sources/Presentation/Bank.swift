import Foundation

public struct Bank {
    public let key: String
    public let description: String
    
    public init(response: BankResponse) {
        self.key = response.key
        self.description = response.description
    }
}
