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
            .filter { [weak self] _ in self?.output.sectionType == .coupon }
            .map { _ in
                return .myCoupons
            }
            .subscribe(output.route)
            .store(in: &cancellables)

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
        let eventName: EventName
        switch output.sectionType {
        case .visit:
            eventName = .clickVisitedStore
        case .favorite:
            eventName = .clickFavoritedStore
        case .coupon:
            eventName = .clickCoupon
        }
        logManager.sendEvent(.init(screen: output.screenName, eventName: eventName, extraParameters: [
            .storeId: store.id,
            .type: store.type.rawValue
        ]))
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
