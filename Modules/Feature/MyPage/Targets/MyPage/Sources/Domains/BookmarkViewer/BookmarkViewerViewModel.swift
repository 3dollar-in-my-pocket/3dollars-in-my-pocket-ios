import Foundation
import Combine

import Common
import Networking
import Model
import AppInterface
import Log

public final class BookmarkViewerViewModel: BaseViewModel {
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let didTapStore = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .bookmarkListViewer
        let sections = CurrentValueSubject<[BookmarkViewerSection], Never>([])
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
    }
    
    struct Config {
        let folderId: String
    }
    
    struct State {
        var hasMore = true
        var cursor: String? = nil
        let size = 20
        var title = ""
        var description = ""
        var totalCount = 0
        var stores: [StoreApiResponse] = []
        var user: UserApiResponse?
    }
    
    enum Route {
        case pushUserStoreDetail(String)
        case pushBossStoreDetail(String)
        case presentSigninDialog
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let config: Config
    private let bookmarkService: BookmarkServiceProtocol
    private var appModuleInterface: AppModuleInterface
    private let logManager: LogManagerProtocol
    private let preference = Preference.shared
    
    init(
        config: Config,
        bookmarkService: BookmarkServiceProtocol = BookmarkService(),
        appModuleInterface: AppModuleInterface = Environment.appModuleInterface,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.bookmarkService = bookmarkService
        self.appModuleInterface = appModuleInterface
        self.logManager = logManager
        
        super.init()
    }
    
    public override func bind() {
        input.loadTrigger
            .sink { [weak self] in
                self?.fetchBookmarkFolder()
            }
            .store(in: &cancellables)
        
        let didTapStore = input.didTapStore.share()
        
        didTapStore
            .withUnretained(self)
            .filter { (owner: BookmarkViewerViewModel, _) in
                owner.preference.authToken.isEmpty
            }
            .map { _ in Route.presentSigninDialog }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        didTapStore
            .withUnretained(self)
            .filter { (owner: BookmarkViewerViewModel, _) in
                owner.preference.authToken.isNotEmpty
            }
            .compactMap { (owner: BookmarkViewerViewModel, index: Int) -> Route? in
                guard let store = owner.state.stores[safe: index] else { return nil }
                
                owner.sendClickStoreLog(store)
                switch store.storeType {
                case .bossStore:
                    return .pushBossStoreDetail(store.storeId)
                case .userStore:
                    return .pushUserStoreDetail(store.storeId)
                case .unknown:
                    return nil
                }
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func fetchBookmarkFolder() {
        Task { [weak self] in
            guard let self else { return }
            
            output.showLoading.send(true)
            let result = await bookmarkService.fetchBookmarkFolder(
                folderId: config.folderId,
                size: state.size,
                cursor: state.cursor
            )
            output.showLoading.send(false)
            
            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.cursor = response.cursor.nextCursor
                state.totalCount = response.cursor.totalCount
                state.stores += response.favorites
                state.title = response.name
                state.description = response.introduction
                state.user = response.user
                
                updateSections()
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func updateSections() {
        guard let user = state.user else { return }
        let overviewUIModel = BookmarkViewerOverviewCell.UIModel(
            title: state.title,
            description: state.description,
            user: user
        )
        
        let overViewSection = BookmarkViewerSection(type: .overview, items: [.overview(overviewUIModel)])
        let storeSection = BookmarkViewerSection(
            type: .storeList(count: state.totalCount),
            items: state.stores.map { .store($0) }
        )
        
        output.sections.send([overViewSection, storeSection])
    }
}

// MARK: Log
private extension BookmarkViewerViewModel {
    func sendClickStoreLog(_ store: StoreApiResponse) {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickStore, extraParameters: [
            .storeId: store.storeId,
            .type: store.storeType.rawValue
        ]))
    }
}
