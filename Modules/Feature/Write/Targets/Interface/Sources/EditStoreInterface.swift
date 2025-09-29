import Combine
import Model

public struct EditStoreViewModelConfig {
    public let store: UserStoreResponse
    
    public init(store: UserStoreResponse) {
        self.store = store
    }
}

public protocol EditStoreViewModelInterface {
    var onEdit: PassthroughSubject<UserStoreResponse, Never> { get }
    
    init(config: EditStoreViewModelConfig)
}
