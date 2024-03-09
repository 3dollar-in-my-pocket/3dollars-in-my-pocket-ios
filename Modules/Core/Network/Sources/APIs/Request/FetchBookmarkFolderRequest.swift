import Foundation

import Model

struct FetchBookmarkFolderRequest: RequestType {
    let folderId: String
    let size: Int
    let cursor: String?
    
    public init(folderId: String, size: Int, cursor: String?) {
        self.folderId = folderId
        self.size = size
        self.cursor = cursor
    }
    
    var param: Encodable? {
        return Param(size: size, cursor: cursor)
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/folder/\(folderId)/favorite-stores"
    }
}

extension FetchBookmarkFolderRequest {
    struct Param: Encodable {
        let size: Int
        let cursor: String?
    }
}
