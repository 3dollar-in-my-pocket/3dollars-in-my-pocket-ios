import Combine
import Model
import Log

public struct EditStoreViewModelConfig {
    public let store: UserStoreResponse
    public let fromScreen: ScreenName?
    public let imageCount: Int?

    public init(store: UserStoreResponse, fromScreen: ScreenName?, imageCount: Int? = nil) {
        self.store = store
        self.fromScreen = fromScreen
        self.imageCount = imageCount
    }
}

public protocol EditStoreViewModelInterface {
    var onEdit: PassthroughSubject<UserStoreResponse, Never> { get }
    
    init(config: EditStoreViewModelConfig)
}
