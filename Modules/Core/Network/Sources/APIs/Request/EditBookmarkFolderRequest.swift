import Foundation

import Model

struct EditBookmarkFolderRequest: RequestType {
    let input: EditBookmarkFolderInput
    let folderType: FolderType
    
    var param: Encodable? {
        return input
    }
    
    var method: RequestMethod {
        return .put
    }
    
    var header: HTTPHeaderType {
        return .auth
    }
    
    var path: String {
        return "/api/v2/\(folderType.rawValue)/folder"
    }
}
