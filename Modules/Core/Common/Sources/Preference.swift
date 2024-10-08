import Foundation
import Model
import CoreLocation

public final class Preference {
    public static let shared = Preference()
    
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
    
    public var authToken: String {
        get {
            return instance.string(forKey: "KEY_TOKEN") ?? ""
        }
        set {
            self.instance.set(newValue, forKey: "KEY_TOKEN")
        }
    }
    
    public var isAnonymousUser: Bool {
        get {
            return instance.bool(forKey: "KEY_IS_ANONYMOUS_USER")
        }
        set {
            instance.set(newValue, forKey: "KEY_IS_ANONYMOUS_USER")
        }
    }
    
    public var shareLink: String {
        get {
            let storeType = instance.string(forKey: "KEY_SHARE_LINK_STORE_TYPE") ?? ""
            let storeId = instance.string(forKey: "KEY_SHARE_LINK_STORE_ID") ?? ""
            
            if storeType.isEmpty {
                return ""
            } else {
                return "\(storeType):\(storeId)"
            }
        }
        
        set {
            if newValue.isEmpty {
                instance.set("", forKey: "KEY_SHARE_LINK_STORE_TYPE")
                instance.set("", forKey: "KEY_SHARE_LINK_STORE_ID")
            } else {
                let splitArray = newValue.split(separator: ":")
                let storeType = splitArray.first ?? "streetFood"
                let storeId = splitArray.last ?? ""
                
                instance.set(storeType, forKey: "KEY_SHARE_LINK_STORE_TYPE")
                instance.set(storeId, forKey: "KEY_SHARE_LINK_STORE_ID")
            }
        }
    }
    
    public var splashAd: AdvertisementResponse? {
        get {
            return instance.getData(forKey: "KEY_SPLASH_AD")
        }
        set {
            guard let newValue else { return }
            instance.set(encodable: newValue, forKey: "KEY_SPLASH_AD")
        }
    }
    
    public func clear() {
        instance.removeObject(forKey: "KEY_USER_ID")
        instance.removeObject(forKey: "KEY_TOKEN")
    }
}
