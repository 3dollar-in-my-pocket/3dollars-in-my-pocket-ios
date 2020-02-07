protocol APIServiceType {
}

extension APIServiceType {
    static func url(_ path: String) -> String {
        return "http://15.164.234.37:8080/\(path)"
    }
    
    static func jsonHeader() -> [String: String] {
        return ["Accept": "application/json"]
    }
    
    static func defaultHeader() -> [String: String] {
        return ["Authorization": UserDefaultsUtil.getUserToken()!]
    }
    
    static func jsonWithTokenHeader() -> [String: String] {
        return ["Accept": "application/json",
                "Authorization": UserDefaultsUtil.getUserToken()!]
    }
}
