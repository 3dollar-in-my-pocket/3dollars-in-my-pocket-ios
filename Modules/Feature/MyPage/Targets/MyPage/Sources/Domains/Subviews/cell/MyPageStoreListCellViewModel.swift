import Combine

import Common
import Model
import Networking
import Log

final class MyPageStoreListCellViewModel: BaseViewModel {
    struct Input {
        let didSelect = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let items: [MyPageStore]
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case storeDetail(Int)
        case bossStoreDetail(String)
    }
    
    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    init(items: [MyPageStore]) {
        self.output = Output(items: items)

        super.init()
    }

    override func bind() {
        super.bind()

        input.didSelect
            .compactMap { [weak self] in self?.output.items[safe: $0]?.store }
            .compactMap { store in 
                switch store.type {
                case .userStore:
                    if let id = Int(store.id) {
                        return .storeDetail(id)
                    }
                case .bossStore:
                    return .bossStoreDetail(store.id)
                case .unknown:
                    return nil
                }
                return nil
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
}

extension MyPageStoreListCellViewModel: Hashable {
    static func == (lhs: MyPageStoreListCellViewModel, rhs: MyPageStoreListCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
