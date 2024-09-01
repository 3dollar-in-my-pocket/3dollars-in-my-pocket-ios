import Combine

import Common
import Model

final class BookmarkStoreCellViewModel: BaseViewModel {
    struct Input {
        let didTapDelete = PassthroughSubject<Void, Never>()
        let index = PassthroughSubject<Int, Never>()
        let didChangeDeleteMode = PassthroughSubject<Bool, Never>()
    }
    
    struct Output {
        var store: StoreResponse
        let isDeleteMode: CurrentValueSubject<Bool, Never>
        
        // For relay
        let didTapDelete = PassthroughSubject<Int, Never>()
    }
    
    struct State {
        var index: Int?
    }
    
    struct Config {
        let store: StoreResponse
        let isDeleteModel: Bool
    }
    
    let input = Input()
    let output: Output
    private let config: Config
    private var state = State()
    
    init(config: Config) {
        self.output = Output(
            store: config.store,
            isDeleteMode: .init(config.isDeleteModel)
        )
        self.config = config
        
        super.init()
    }
    
    override func bind() {
        input.didTapDelete
            .withUnretained(self)
            .compactMap { (owner: BookmarkStoreCellViewModel, _) in
                owner.state.index
            }
            .subscribe(output.didTapDelete)
            .store(in: &cancellables)
        
        input.index
            .withUnretained(self)
            .sink { (owner: BookmarkStoreCellViewModel, index: Int) in
                owner.state.index = index
            }
            .store(in: &cancellables)
        
        input.didChangeDeleteMode
            .subscribe(output.isDeleteMode)
            .store(in: &cancellables)
    }
}

extension BookmarkStoreCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BookmarkStoreCellViewModel: Hashable {
    static func == (lhs: BookmarkStoreCellViewModel, rhs: BookmarkStoreCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
