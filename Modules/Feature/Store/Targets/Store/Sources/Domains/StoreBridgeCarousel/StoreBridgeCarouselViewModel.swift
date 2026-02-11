import Combine
import Common
import Model
import Log

extension StoreBridgeCarouselViewModel {
    struct Input {
        let didSelect = PassthroughSubject<Int, Never>()
        let didAppear = PassthroughSubject<Void, Never>()
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
    private let screenName: ScreenName
    private let experimentReference: ExperimentReferenceResponse?
    
    private var hasLoggedImpression = false
    
    lazy var identifier = ObjectIdentifier(self)
    
    var headerTitle: SDText? {
        return headerData.title
    }
    
    init(
        data: StoreRelatedStoresSectionResponse,
        screenName: ScreenName = .storeDetail,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.output = Output(items: data.cards)
        self.headerData = data.header
        self.screenName = screenName
        self.logManager = logManager
        self.experimentReference = data.reference.first
        super.init()
    }
    
    override func bind() {
        input.didSelect
            .compactMap { [weak self] index in self?.output.items[safe: index] }
            .sink { [weak self] card in
                if let link = card.link {
                    Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(link)
                }
                
                self?.sendClickLog(card)
            }
            .store(in: &cancellables)
        
        input.didAppear
            .sink { [weak self] in
                self?.sendImpressionLogIfNeeded()
            }
            .store(in: &cancellables)
    }
    
    private func sendImpressionLogIfNeeded() {
        guard !hasLoggedImpression else { return }
        hasLoggedImpression = true
        
        var extraParameters: [ParameterName : Any]?
        if let experimentReference {
            extraParameters = [
                .experimentType: experimentReference.type,
                .experimentKey: experimentReference.experimentKey,
                .experimentVariant: experimentReference.variant
            ]
        }
        
        logManager.sendEvent(event: ImpressionEvent(
            screen: screenName,
            objectType: .carousel,
            objectId: .recommend,
            extraParameters: extraParameters
        ))
    }
    
    private func sendClickLog(_ card: StoreImagePreviewCard) {
        if let storeRef = card.refs.first(where: { $0.type.lowercased() == "store" }),
           let storeId = Int(storeRef.storeId) {
            
            var extraParameters: [ParameterName : Any] = [:]
            if let experimentReference {
                extraParameters = [
                    .experimentType: experimentReference.type,
                    .experimentKey: experimentReference.experimentKey,
                    .experimentVariant: experimentReference.variant
                ]
            }
            
            extraParameters.updateValue(storeId, forKey: .storeId)
            extraParameters.updateValue(storeRef.storeType, forKey: .storeType)
            
            logManager.sendEvent(event: ClickEvent(
                screen: screenName,
                objectType: .card,
                objectId: .recommendStore,
                extraParameters: extraParameters
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

