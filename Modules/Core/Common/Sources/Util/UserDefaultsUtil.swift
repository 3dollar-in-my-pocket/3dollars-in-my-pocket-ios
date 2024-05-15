import Foundation
import Model
import CoreLocation

public final class UserDefaultsUtil {
    public static let shared = UserDefaultsUtil()
    
    private let instance: UserDefaults
    
    public init(name: String? = nil) {
        if let name {
            UserDefaults().removePersistentDomain(forName: name)
            instance = UserDefaults(suiteName: name)!
        } else {
            instance = UserDefaults.standard
        }
    }
    
    public var userCurrentLocation: CLLocation {
        set {
            instance.set(newValue.coordinate.latitude, forKey: "KEY_CURRENT_LATITUDE")
            instance.set(newValue.coordinate.longitude, forKey: "KEY_CURRENT_LONGITUDE")
        }
        get {
            let latitude = instance.double(forKey: "KEY_CURRENT_LATITUDE")
            let longitude = instance.double(forKey: "KEY_CURRENT_LONGITUDE")
            
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }

    /// 커뮤니티 동네 인기가게 - 유저가 선택한 동네
    public var communityPopularStoreNeighborhoods: CommunityNeighborhoods {
        set {
            instance.set(newValue.district, forKey: "KEY_COMMUNITY_POPULAR_STORE_NEIGHBORHOODS_DISTRICT")
            instance.set(newValue.description, forKey: "KEY_COMMUNITY_POPULAR_STORE_NEIGHBORHOODS_DESCRIPTION")
        }
        get {
            guard let district = instance.string(forKey: "KEY_COMMUNITY_POPULAR_STORE_NEIGHBORHOODS_DISTRICT"),
                  let descrition = instance.string(forKey: "KEY_COMMUNITY_POPULAR_STORE_NEIGHBORHOODS_DESCRIPTION") else {
                return .defaultValue
            }

            return CommunityNeighborhoods(district: district, description: descrition, isSelected: true)
        }
    }
    
    public var userId: Int {
        set {
            instance.set(newValue, forKey: "KEY_USER_ID")
        }
        get {
            return instance.integer(forKey: "KEY_USER_ID")
        }
    }
    
    public var subscribedMarketingTopic: Bool {
        get {
            instance.bool(forKey: "KEY_SUBSCRIBE_MARKETING_TOPIC")
        }
        set {
            instance.set(newValue, forKey: "KEY_SUBSCRIBE_MARKETING_TOPIC")
        }
    }
    
    public func setShownMainBannerDate(id: Int) {
        instance.set(DateUtils.todayString(), forKey: "KEY_SHOWN_MAIN_BANNER_\(id)")
    }
    
    public func getShownMainBannerDate(id: Int) -> String? {
        return instance.string(forKey: "KEY_SHOWN_MAIN_BANNER_\(id)")
    }
    
    public var isShownFilterTooltip: Bool {
        set {
            instance.set(newValue, forKey: "KEY_IS_SHOWN_FILTER_TOOLTIP")
        }
        get {
            return instance.bool(forKey: "KEY_IS_SHOWN_FILTER_TOOLTIP")
        }
    }
}
