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
        let didTapEdit = PassthroughSubject<Void, Never>()
        let didTapDelete = PassthroughSubject<MyVisitStore, Never>()
        let didConfirmDelete = PassthroughSubject<MyVisitStore, Never>()
    }

    struct Output {
        let screenName: ScreenName = .visitedList
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sections = CurrentValueSubject<[VisitStoreListSection], Never>([])
        let isEditing = CurrentValueSubject<Bool, Never>(false)
    }

    struct State {
        var nextCursor: String?
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
        var items: [MyVisitStore] = []
    }

    enum Route {
        case storeDetail(Int)
        case bossStoreDetail(String)
        case presentDeleteAlert(MyVisitStore)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let myPageRepository: MyPageRepository
    private let visitRepository: VisitRepository
    private let preference = Preference.shared
    private let logManager: LogManagerProtocol

    init(
        myPageRepository: MyPageRepository = MyPageRepositoryImpl(),
        visitRepository: VisitRepository = VisitRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.myPageRepository = myPageRepository
        self.visitRepository = visitRepository
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        bindEdit()
        
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
                    owner.reloadItems()
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
            .filter { owner, _ in owner.output.isEditing.value.isNot }
            .compactMap { owner, indexPath -> PlatformStore? in
                guard let item = owner.output.sections.value[safe: indexPath.section]?.items[safe: indexPath.item],
                      case .store(let store, _) = item else { return nil }
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
    
    private func bindEdit() {
        input.didTapEdit
            .withUnretained(self)
            .sink { owner, _ in
                owner.sendClickEdit()
                owner.setEditing(owner.output.isEditing.value.isNot)
            }
            .store(in: &cancellables)

        input.didTapDelete
            .map { Route.presentDeleteAlert($0) }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didConfirmDelete
            .withUnretained(self)
            .sink { owner, item in
                owner.sendClickDeleteVisit(item)
                Task { [weak owner] in
                    await owner?.deleteVisit(item)
                }
                .store(in: owner.taskBag)
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func deleteVisit(_ item: MyVisitStore) async {
        output.showLoading.send(true)
        let result = await visitRepository.deleteStoreVisit(visitId: item.visitId)
        output.showLoading.send(false)

        switch result {
        case .success(let message):
            state.items.removeAll { $0.visitId == item.visitId }
            reloadItems()
            if let message, message.isNotEmpty {
                output.showToast.send(message)
            }
        case .failure(let error):
            if case .errorContainer(let container) = error as? NetworkError,
               container.resultCode != "UA000",
               let message = container.message,
               message.isNotEmpty {
                output.showToast.send(message)
            } else {
                output.showErrorAlert.send(error)
            }
        }
    }

    private func reloadItems() {
        if state.items.isEmpty {
            setEditing(false)
        } else {
            updateDataSource()
        }
    }

    private func setEditing(_ isEditing: Bool) {
        output.isEditing.send(isEditing)
        updateDataSource()
    }

    private func updateDataSource() {
        let isEditing = output.isEditing.value
        let sections: [VisitStoreListSection] = state.items.reduce(into: []) { result, element in
            if let sectionIndex = result.firstIndex(where: { $0.visitDate == element.visitDate }) {
                result[sectionIndex].items.append(.store(element, isEditing: isEditing))
            } else {
                let newSection = VisitStoreListSection(
                    visitDate: element.visitDate,
                    items: [.store(element, isEditing: isEditing)]
                )
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
        logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .card,
            objectId: .store,
            extraParameters: [
                .storeId: store.id,
                .storeType: store.type.rawValue
            ]
        ))
    }

    func sendClickEdit() {
        logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .edit
        ))
    }

    func sendClickDeleteVisit(_ item: MyVisitStore) {
        logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .deleteVisit,
            extraParameters: [
                .storeId: item.store.id,
                .storeType: item.store.type.rawValue,
                .visitId: item.visitId
            ]
        ))
    }
}
