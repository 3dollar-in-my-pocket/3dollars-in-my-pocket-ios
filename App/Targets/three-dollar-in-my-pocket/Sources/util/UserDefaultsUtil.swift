import Foundation
import CoreLocation

import AppInterface
import Networking

struct UserDefaultsUtil: UserDefaultProtocol {
    private let KEY_TOKEN = "KEY_TOKEN"
    private let KEY_USER_ID = "KEY_USER_ID"
    private let KEY_IS_ANONYMOUS_USER = "KEY_IS_ANONYMOUS_USER"
    static let KEY_SHARE_LINK_STORE_TYPE = "KEY_SHARE_LINK_STORE_TYPE"
    static let KEY_SHARE_LINK_STORE_ID = "KEY_SHARE_LINK_STORE_ID"
    
    let instance: UserDefaults
    
    
    init(name: String? = nil) {
        if let name = name {
            UserDefaults().removePersistentDomain(forName: name)
            instance = UserDefaults(suiteName: name)!
        } else {
            instance = UserDefaults.standard
        }
    }
    
    var authToken: String {
        get {
            return self.instance.string(forKey: KEY_TOKEN) ?? ""
        }
        set {
            self.instance.set(newValue, forKey: KEY_TOKEN)
        }
    }
    
    var userId: Int {
        get {
            return self.instance.integer(forKey: KEY_USER_ID)
        }
        set {
            self.instance.integer(forKey: KEY_USER_ID)
        }
    }
    
    var isAnonymousUser: Bool {
        get {
            return self.instance.bool(forKey: self.KEY_IS_ANONYMOUS_USER)
        }
        set {
            self.instance.set(newValue, forKey: self.KEY_IS_ANONYMOUS_USER)
        }
    }
    
    
    var shareLink: String {
        get {
            let storeType = self.instance.string(
                forKey: UserDefaultsUtil.KEY_SHARE_LINK_STORE_TYPE
            ) ?? ""
            let storeId = self.instance.string(
                forKey: UserDefaultsUtil.KEY_SHARE_LINK_STORE_ID
            ) ?? ""
            
            if storeType.isEmpty {
                return ""
            } else {
                return "\(storeType):\(storeId)"
            }
        }
        
        set {
            if newValue.isEmpty {
                self.instance.set(
                    "",
                    forKey: UserDefaultsUtil.KEY_SHARE_LINK_STORE_TYPE
                )
                self.instance.set(
                    "",
                    forKey: UserDefaultsUtil.KEY_SHARE_LINK_STORE_ID
                )
            } else {
                let splitArray = newValue.split(separator: ":")
                let storeType = splitArray.first ?? "streetFood"
                let storeId = splitArray.last ?? ""
                
                self.instance.set(
                    storeType,
                    forKey: UserDefaultsUtil.KEY_SHARE_LINK_STORE_TYPE
                )
                self.instance.set(
                    storeId,
                    forKey: UserDefaultsUtil.KEY_SHARE_LINK_STORE_ID
                )
            }
        }
    }
    
    func clear() {
        self.instance.removeObject(forKey: KEY_USER_ID)
        self.instance.removeObject(forKey: KEY_TOKEN)
    }
}
