import Foundation

public struct ChangeMarketingConsentInput: Encodable {
    public let marketingConsent: String
    
    public init(marketingConsent: String) {
        self.marketingConsent = marketingConsent
    }
}
