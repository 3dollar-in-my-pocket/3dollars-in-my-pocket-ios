import Combine
import Model
import Log

public struct EditStoreViewModelConfig {
    public let store: UserStoreResponse
    public let fromScreen: ScreenName?
    
    public init(store: UserStoreResponse, fromScreen: ScreenName?) {
        self.store = store
        self.fromScreen = fromScreen
    }
}

public protocol EditStoreViewModelInterface {
    var onEdit: PassthroughSubject<UserStoreResponse, Never> { get }
    
    init(config: EditStoreViewModelConfig)
}
