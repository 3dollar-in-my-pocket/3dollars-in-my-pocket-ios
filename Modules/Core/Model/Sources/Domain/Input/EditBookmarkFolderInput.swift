import Foundation

public struct EditBookmarkFolderInput: Encodable {
    public let name: String
    public let introduction: String
    
    public init(name: String, introduction: String) {
        self.name = name
        self.introduction = introduction
    }
}
