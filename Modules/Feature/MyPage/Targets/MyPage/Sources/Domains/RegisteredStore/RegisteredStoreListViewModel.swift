import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class RegisteredStoreListViewModel: BaseViewModel {
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<Int, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .registeredStore
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sectionItems = CurrentValueSubject<[UserStoreWithVisitsApiResponse], Never>([])
        let totalCount = CurrentValueSubject<Int, Never>(0)
    }

    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
    }

    enum Route {
        case storeDetail(Int)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let myPageService: MyPageServiceProtocol
    private let preference = Preference.shared
    private let logManager: LogManagerProtocol

    init(
        myPageService: MyPageServiceProtocol = MyPageService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.myPageService = myPageService 
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        
        input.loadTrigger
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.nextCursor = nil
                owner.state.hasMore = false
                owner.output.showLoading.send(true)
            })
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.myPageService.fetchMyStores(
                    input: .init(size: 20, cursor: owner.state.nextCursor), 
                    latitude: owner.preference.userCurrentLocation.coordinate.latitude, 
                    longitude: owner.preference.userCurrentLocation.coordinate.longitude
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.output.totalCount.send(response.cursor.totalCount)
                    owner.output.sectionItems.send(response.contents)
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .filter { owner, row in
                owner.canLoadMore(willDisplayRow: row)
            }
            .sink { owner, _ in
                owner.state.loadMore.send()
            }
            .store(in: &cancellables)
        
        state.loadMore
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.myPageService.fetchMyStores(
                    input: .init(size: 20, cursor: owner.state.nextCursor), 
                    latitude: owner.preference.userCurrentLocation.coordinate.latitude, 
                    longitude: owner.preference.userCurrentLocation.coordinate.longitude
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.output.totalCount.send(response.cursor.totalCount)
                    var sectionItems = owner.output.sectionItems.value
                    sectionItems.append(contentsOf: response.contents)
                    owner.output.sectionItems.send(sectionItems)
                    
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.didSelectItem
            .withUnretained(self)
            .compactMap { owner, index in owner.output.sectionItems.value[safe: index]?.store }
            .handleEvents(receiveOutput: { [weak self] store in
                self?.sendClickStoreLog(store)
            })
            .map { .storeDetail($0.storeId) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == output.sectionItems.value.count - 1 && state.hasMore
    }
}


// MARK: Log
private extension RegisteredStoreListViewModel {
    func sendClickStoreLog(_ store: UserStoreApiResponse) {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickStore, extraParameters: [
            .storeId: store.storeId,
            .type: StoreType.userStore.rawValue
        ]))
    }
}
