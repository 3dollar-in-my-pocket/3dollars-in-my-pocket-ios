import Foundation
import Combine

import Common
import Networking
import Model
import Log

final class SearchAddressViewModel: BaseViewModel {
    struct Input {
        let inputKeyword = PassthroughSubject<String, Never>()
        let didTapAddress = PassthroughSubject<Int, Never>()
        let didScroll = PassthroughSubject<Void, Never>()
        let firstLoad = PassthroughSubject<Void, Never>()
        let willDisplayRecentSearchCell = PassthroughSubject<Int, Never>()
        let didTapRecentSearchAddress = PassthroughSubject<Int, Never>()
        let didTapClearButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .searchAddress
        let sections = PassthroughSubject<[SearchAddressSection], Never>()
        let isHiddenClear = PassthroughSubject<Bool, Never>()
        let hideKeyboard = PassthroughSubject<Void, Never>()
        let selectAddress = PassthroughSubject<PlaceDocument, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct State {
        var address: [PlaceDocument] = []
        var recentSearchAddress: [PlaceResponse] = []
        var recentSearchNextCursor: String?
        var recentSearchHasMore: Bool = false
        var isLoading: Bool = false
    }
    
    enum Route {
        case dismiss
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let mapRepository: MapRepository
    private let userService: UserServiceProtocol
    private let logManager: LogManagerProtocol
    
    init(
        mapRepository: MapRepository = MapRepositoryImpl(),
        userService: UserServiceProtocol = UserService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.mapRepository = mapRepository
        self.userService = userService
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        bindRecentSearch()
        
        input.inputKeyword
            .filter { !$0.isEmpty }
            .throttle(for: 0.5, scheduler: RunLoop.current, latest: true)
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewModel, keyword: String) in
                owner.searchAddress(keyword: keyword)
            })
            .store(in: &cancellables)
        
        input.inputKeyword
            .map { $0.isEmpty }
            .subscribe(output.isHiddenClear)
            .store(in: &cancellables)
        
        input.didTapAddress
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewModel, index: Int) in
                guard let selectedAddress = owner.state.address[safe: index] else { return }
                
                owner.selectAddress(document: selectedAddress)
                owner.saveAddress(document: selectedAddress)
                owner.sendClickLog(placeDocument: selectedAddress, type: "SEARCH")
            })
            .store(in: &cancellables)
        
        input.didScroll
            .mapVoid
            .subscribe(output.hideKeyboard)
            .store(in: &cancellables)
    }
    
    private func bindRecentSearch() {
        let recentSearchPageSize: Int = 20
        
        let loadMore = input.willDisplayRecentSearchCell
            .withUnretained(self)
            .filter { owner, row in
                owner.canLoadMoreRecentSearch(willDisplayRow: row)
            }
            .mapVoid
            .share()
        
        let loadRecentSearch = input.firstLoad
            .merge(with: loadMore)
            .withUnretained(self)
            .filter { owner, _ in
                owner.state.isLoading.isNot
            }
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.isLoading = true
            })
            .asyncMap { owner, _ in
                await owner.userService.getMyPlaces(
                    placeType: .recentSearch,
                    input: CursorRequestInput(
                        size: recentSearchPageSize,
                        cursor: owner.state.recentSearchNextCursor
                    )
                )
            }
            .share()
        
        loadRecentSearch
            .compactMapValue()
            .withUnretained(self)
            .sink { owner, result in
                owner.handleRecentSearchAddressResult(result)
            }
            .store(in: &cancellables)
        
        loadRecentSearch
            .compactMapError()
            .subscribe(output.showErrorAlert)
            .store(in: &cancellables)
        
        input.didTapRecentSearchAddress
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewModel, index: Int) in
                guard let selectedAddress = owner.state.recentSearchAddress[safe: index] else { return }
                
                let document = PlaceDocument(
                    addressName: selectedAddress.addressName ?? "",
                    y: String(selectedAddress.location.latitude),
                    x: String(selectedAddress.location.longitude),
                    roadAddressName: selectedAddress.roadAddressName ?? "",
                    placeName: selectedAddress.placeName
                )
                owner.selectAddress(document: document)
                owner.saveAddress(document: document)
                owner.sendClickLog(placeDocument: document, type: "RECENT")
            })
            .store(in: &cancellables)
        
        input.inputKeyword
            .filter { $0.isEmpty }
            .mapVoid
            .merge(with: input.didTapClearButton.mapVoid)
            .withUnretained(self)
            .sink { owner, _ in
                owner.reloadRecentSearchDataSource()
            }
            .store(in: &cancellables)
    }
    
    private func searchAddress(keyword: String) {
        Task {
            let result = await mapRepository.searchAddress(keyword: keyword)
            
            switch result {
            case .success(let response):
                state.address = response.documents
                let sectionItems: [SearchAddressSectionItem] = response.documents.map { .address($0) }
                output.sections.send([
                    .init(type: .banner, items: [.banner]),
                    .init(type: .address, items: sectionItems)
                ])
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func selectAddress(document: PlaceDocument) {
        output.selectAddress.send(document)
        output.route.send(.dismiss)
    }
    
    private func canLoadMoreRecentSearch(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.recentSearchAddress.count - 1 && state.recentSearchHasMore
    }
    
    private func handleRecentSearchAddressResult(_ response: ContentsWithCursorResponse<PlaceResponse>) {
        state.isLoading = false
        state.recentSearchHasMore = response.cursor.hasMore
        state.recentSearchNextCursor = response.cursor.nextCursor
        state.recentSearchAddress.append(contentsOf: response.contents)
        reloadRecentSearchDataSource()
    }
    
    private func saveAddress(document: PlaceDocument) {
        Task {
            let input = SaveMyPlaceInput(
                location: .init(latitude: document.y, longitude: document.x),
                placeName: document.placeName,
                addressName: document.addressName,
                roadAddressName: document.roadAddressName
            )
            
            let _ = await userService.saveMyPlace(
                placeType: .recentSearch,
                input: input
            )
        }
    }
    
    private func bindRecentSearchCellViewModel(with data: PlaceResponse) -> RecentSearchAddressCellViewModel {
        let cellViewModel = RecentSearchAddressCellViewModel(data: data)
        
        cellViewModel.output.deleteRecentSearch
            .withUnretained(self)
            .sink { owner, placeId in
                Task {
                    let _ = await owner.userService.deleteMyPlace(
                        placeType: .recentSearch,
                        placeId: placeId
                    )
                }
                
                owner.state.recentSearchAddress.removeAll(where: { $0.placeId == placeId })
                owner.reloadRecentSearchDataSource()
            }
            .store(in: &cellViewModel.cancellables)
        
        return cellViewModel
    }
    
    private func reloadRecentSearchDataSource() {
        let sectionItems: [SearchAddressSectionItem] = state.recentSearchAddress.map { .recentSearch(bindRecentSearchCellViewModel(with: $0)) }
        output.sections.send([
            .init(type: .banner, items: [.banner]),
            .init(type: .recentSearch, items: sectionItems)
        ])
    }
    
    private func sendClickLog(placeDocument: PlaceDocument, type: String) {
        logManager.sendEvent(
            .init(
                screen: output.screenName,
                eventName: .clickAddress,
                extraParameters: [
                    .buildingName: placeDocument.placeName,
                    .address: placeDocument.addressName,
                    .type: type
                ]
            )
        )
    }
}
