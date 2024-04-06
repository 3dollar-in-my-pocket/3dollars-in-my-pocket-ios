import Foundation
import UIKit

struct HTTPUtils {
    static let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String ?? ""
    
    static let userAgent: String = {
        let info = Bundle.main.infoDictionary
        let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
        (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
        "Unknown"
        let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"
        
        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = "iOS"
            
            return "\(osName) \(versionString)"
        }()
        
        return "\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
    }()
}
