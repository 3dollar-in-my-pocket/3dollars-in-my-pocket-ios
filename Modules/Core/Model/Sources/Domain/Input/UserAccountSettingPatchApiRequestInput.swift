import Foundation

public struct UserAccountSettingPatchApiRequestInput: Encodable {
    public let enableActivitiesPush: Bool
    public let marketingConsent: MarketingConsent
    
    public init(enableActivitiesPush: Bool, marketingConsent: MarketingConsent) {
        self.enableActivitiesPush = enableActivitiesPush
        self.marketingConsent = marketingConsent
    }
}
