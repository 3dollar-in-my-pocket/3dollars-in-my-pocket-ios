import Foundation

struct ChangeMarketingConsentInput: Encodable {
    let marketingConsent: String
    
    public init(marketingConsent: String) {
        self.marketingConsent = marketingConsent
    }
}
