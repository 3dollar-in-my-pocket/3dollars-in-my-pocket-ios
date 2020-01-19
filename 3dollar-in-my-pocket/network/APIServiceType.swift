protocol APIServiceType {
}

extension APIServiceType {
    static func url(_ path: String) -> String {
        return "http://13.209.40.203:8080/\(path)"
    }
    
    static func jsonHeader() -> [String: String] {
        return ["Accept": "application/json"]
    }
    
    static func defaultHeader() -> [String: String] {
        return ["Authorization": UserDefaultsUtil.getUserToken()!]
    }
}
