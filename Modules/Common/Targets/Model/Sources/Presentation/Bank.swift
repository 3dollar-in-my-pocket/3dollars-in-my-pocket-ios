import Foundation

public struct Bank {
    let key: String
    let description: String
    
    public init(response: BankResponse) {
        self.key = response.key
        self.description = response.description
    }
}
