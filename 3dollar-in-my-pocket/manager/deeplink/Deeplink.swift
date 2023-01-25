enum Deeplink {
    case bookmark(folderId: String)
    
    var path: String {
        switch self {
        case .bookmark:
            return "bookmark"
        }
    }
    
    var parameters: [String: String]? {
        
    }
}
