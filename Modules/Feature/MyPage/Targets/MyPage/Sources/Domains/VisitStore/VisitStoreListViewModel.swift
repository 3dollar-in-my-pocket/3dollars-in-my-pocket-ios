import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class VisitStoreListViewModel: BaseViewModel {
    private static let size: Int = 20
    
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<IndexPath, Never>()
        let willDisplaytCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .visitedList
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sections = CurrentValueSubject<[VisitStoreListSection], Never>([])
    }

    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
        var items: [MyVisitStore] = []
    }

    enum Route {
        case storeDetail(Int)
        case bossStoreDetail(String)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let myPageRepository: MyPageRepository
    private let preference = Preference.shared
    private let logManager: LogManagerProtocol

    init(
        myPageRepository: MyPageRepository = MyPageRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.myPageRepository = myPageRepository 
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
                let input = CursorRequestInput(size: Self.size, cursor: owner.state.nextCursor)
                return await owner.myPageRepository.fetchMyStoreVisits(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.items = response.contents.map { MyVisitStore(response: $0) }
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.willDisplaytCell
            .withUnretained(self)
            .filter { owner, section in
                owner.canLoadMore(willDisplaySection: section)
            }
            .sink { owner, _ in
                owner.state.loadMore.send()
            }
            .store(in: &cancellables)
        
        state.loadMore
            .withUnretained(self)
            .asyncMap { owner, input in
                let input = CursorRequestInput(size: Self.size, cursor: owner.state.nextCursor)
                return await owner.myPageRepository.fetchMyStoreVisits(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.items.append(contentsOf: response.contents.map { MyVisitStore(response: $0) })
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure:
                    break
                }
            }
            .store(in: &cancellables)
        
        input.didSelectItem
            .withUnretained(self)
            .compactMap { owner, indexPath -> PlatformStore? in
                guard let item = owner.output.sections.value[safe: indexPath.section]?.items[safe: indexPath.item],
                      case .store(let store) = item else { return nil }
                return store.store
            }
            .handleEvents(receiveOutput: { [weak self] store in
                self?.sendClickStore(store)
            })
            .compactMap { store -> Route? in
                switch store.type {
                case .userStore:
                    if let id = Int(store.id) {
                        return .storeDetail(id)
                    } else {
                        return nil
                    }
                case .bossStore:
                    return .bossStoreDetail(store.id)
                case .unknown:
                    return nil
                }
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func updateDataSource() {
        let sections: [VisitStoreListSection] = state.items.reduce(into: []) { result, element in
            if let sectionIndex = result.firstIndex(where: { $0.visitDate == element.visitDate }) {
                result[sectionIndex].items.append(.store(element))
            } else {
                let newSection = VisitStoreListSection(visitDate: element.visitDate, items: [.store(element)])
                result.append(newSection)
            }
        }
        
        output.sections.send(sections)
    }
    
    private func canLoadMore(willDisplaySection: Int) -> Bool {
        return willDisplaySection == output.sections.value.count - 1 && state.hasMore
    }
}

// MARK: Log
private extension VisitStoreListViewModel {
    func sendClickStore(_ store: PlatformStore) {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickStore, extraParameters: [
            .storeId: store.id,
            .type: store.type.rawValue
        ]))
    }
}
