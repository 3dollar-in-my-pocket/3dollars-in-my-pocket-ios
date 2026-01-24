import Combine
import Common
import Model
import Log

extension StoreBridgeCarouselViewModel {
    struct Input {
        let didSelect = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let items: [StoreImagePreviewCard]
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case pushStoreDetail(storeId: Int)
    }
}

final class StoreBridgeCarouselViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let logManager: LogManagerProtocol
    private let headerData: StoreRelatedStoresSectionHeaderResponse
    
    lazy var identifier = ObjectIdentifier(self)
    
    var headerTitle: SDText? {
        return headerData.title
    }

    init(data: StoreRelatedStoresSectionResponse, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(items: data.cards)
        self.headerData = data.header
        self.logManager = logManager
        super.init()
    }

    override func bind() {
        input.didSelect
            .compactMap { [weak self] index in self?.output.items[safe: index] }
            .sink { [weak self] card in
                // Extract store ID from the card's reference
                if let storeRef = card.refs.first(where: { $0.type == "store" }),
                   let storeId = Int(storeRef.storeId) {
                    self?.output.route.send(.pushStoreDetail(storeId: storeId))
                    self?.sendClickLog(card)
                }
            }
            .store(in: &cancellables)
    }

    private func sendClickLog(_ card: StoreImagePreviewCard) {
        if let storeRef = card.refs.first(where: { $0.type == "store" }),
           let storeId = Int(storeRef.storeId) {
            logManager.sendEvent(event: ClickEvent(
                screen: .storeDetail,
                objectType: .card,
                objectId: .store,
                extraParameters: [.storeId: storeId]
            ))
        }
    }
}

extension StoreBridgeCarouselViewModel: Hashable {
    static func == (lhs: StoreBridgeCarouselViewModel, rhs: StoreBridgeCarouselViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

