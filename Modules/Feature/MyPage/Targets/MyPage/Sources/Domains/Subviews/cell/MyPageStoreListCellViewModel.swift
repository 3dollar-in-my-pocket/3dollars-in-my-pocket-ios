import Combine

import Common
import Model
import Networking
import Log

extension MyPageStoreListCellViewModel {
    enum SectionType {
        case visit
        case favorite
        case coupon
    }
    
    struct Input {
        let didSelect = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName
        let sectionType: SectionType
        let items: [MyPageStore]
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case storeDetail(Int)
        case bossStoreDetail(String)
        case myCoupons
    }
    
    struct Config {
        let screenName: ScreenName
        let sectionType: SectionType
        let items: [MyPageStore]
    }
}

final class MyPageStoreListCellViewModel: BaseViewModel {
    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output
    
    private let logManager: LogManagerProtocol

    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(screenName: config.screenName, sectionType: config.sectionType, items: config.items)
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        
        input.didSelect
            .compactMap { [weak self] in self?.output.items[safe: $0]?.store }
            .handleEvents(receiveOutput: { [weak self] store in
                self?.sendClickStoreLog(store)
            })
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

// MARK: Log
private extension MyPageStoreListCellViewModel {
    func sendClickStoreLog(_ store: PlatformStore) {
        let objectId: LogObjectId
        switch output.sectionType {
        case .visit:
            objectId = .visitedStore
        case .favorite:
            objectId = .favoritedStore
        case .coupon:
            objectId = .store // coupon은 스펙에 없으므로 기본 store 사용
        }

        logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .card,
            objectId: objectId,
            extraParameters: [
                .storeId: store.id,
                .storeType: store.type.rawValue
            ]
        ))
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
