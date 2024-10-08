import Foundation

import Model

enum BookmarkApi {
    case fetchBookmarkStore(input: FetchBookmarkStoreRequestInput)
    case removeBookmarkStore(storeId: Int)
    case removeAllBookmarkStore
    case editBookmarkFolder(folderType: FolderType, input: EditBookmarkFolderInput)
    case fetchBookmarkFolder(folderId: String, input: FetchBookmarkFolderInput)
}

extension BookmarkApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchBookmarkStore(let input):
            return input
        case .removeBookmarkStore:
            return nil
        case .removeAllBookmarkStore:
            return nil
        case .editBookmarkFolder(let folderType, let input):
            return input
        case .fetchBookmarkFolder(_, let input):
            return input
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchBookmarkStore:
            return .get
        case .removeBookmarkStore:
            return .delete
        case .removeAllBookmarkStore:
            return .delete
        case .editBookmarkFolder:
            return .put
        case .fetchBookmarkFolder:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchBookmarkStore:
            return .json
        case .removeBookmarkStore:
            return .json
        case .removeAllBookmarkStore:
            return .json
        case .editBookmarkFolder:
            return .json
        case .fetchBookmarkFolder:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .fetchBookmarkStore:
            return "/api/v2/my/favorite-stores"
        case .removeBookmarkStore(let storeId):
            return "/api/v2/store/\(storeId)/favorite"
        case .removeAllBookmarkStore:
            return "/api/v2/my/favorite-stores"
        case .editBookmarkFolder(let folderType, _):
            return "/api/v2/\(folderType.rawValue)/folder"
        case .fetchBookmarkFolder(let folderId, _):
            return "/api/v2/folder/\(folderId)/favorite-stores"
        }
    }
}
