import ProjectDescription

public struct DefaultSetting {
    public static let targetVersion: SettingValue = "18.0"
    public static let appVersion: SettingValue = "4.27.0"
    public static let buildNumber: SettingValue = "1"
    public static let organizationName = "macgongmon"
    public static let appIdentifier = "-dollar-in-my-pocket"
    
    public static let baseProductSetting: SettingsDictionary = [
        "IPHONEOS_DEPLOYMENT_TARGET": targetVersion
    ]
}

public extension DefaultSetting {
    static func bundleId(moduleName: String) -> String {
        return "com.\(organizationName).\(appIdentifier).\(moduleName.lowercased())"
    }
}


public extension SettingValue {
    var stringValue: String {
        switch self {
        case .string(let string):
            return string
            
        case .array(let array):
            guard let value = array.first else { return "" }
            return value
            
        @unknown default:
            return ""
        }
    }
}
