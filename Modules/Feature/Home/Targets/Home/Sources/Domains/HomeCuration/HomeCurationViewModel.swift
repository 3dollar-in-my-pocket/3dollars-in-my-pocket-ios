import Foundation
import Combine
import CoreLocation

import Common
import Model
import Networking
import Log

extension HomeCurationViewModel {
    struct Input {
        let setTabId = PassthroughSubject<String?, Never>()
        let setLocation = PassthroughSubject<CLLocation, Never>()
        let didTapCategory = PassthroughSubject<(carouselId: String, categoryId: String), Never>()
        let didTapCarouselCard = PassthroughSubject<(carouselId: String, cardId: String), Never>()
        let willDisplayCarouselCard = PassthroughSubject<(carouselId: String, cardId: String), Never>()
        let didTapAdmobItem = PassthroughSubject<String, Never>()
        let willDisplayAdmobItem = PassthroughSubject<String, Never>()
    }

    struct Output {
        let screenName: ScreenName = .home
        let items = CurrentValueSubject<[HomeCurationSectionItem], Never>([])
        let route = PassthroughSubject<Route, Never>()
        let didSelectStore = PassthroughSubject<HomeCurationSelectedStore, Never>()
    }

    enum Route {
        case deepLink(SDLink)
        case showErrorAlert(Error)
    }

    struct State {
        var tabId: String?
        var location: CLLocation?
        var loadedRequest: LoadedRequest?
        var items: [HomeCurationItem] = []
        var selectedCategoryIds: [String: String] = [:]
        var loadedCategoryIds: [String: String] = [:]
        var cards: [String: [HomeCurationCard]] = [:]
        var impressedCardIds: Set<String> = []
    }

    struct LoadedRequest: Equatable {
        let tabId: String
        let latitude: Double
        let longitude: Double
    }

    struct Dependency {
        let screenRepository: ScreenRepository
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol

        init(
            screenRepository: ScreenRepository = ScreenRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.screenRepository = screenRepository
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }
}

final class HomeCurationViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    private var loadTask: Task<Void, Never>?
    private var cardTasks: [String: Task<Void, Never>] = [:]
    private var storeTask: Task<Void, Never>?

    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }

    override func bind() {
        input.setTabId
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, tabId: String?) in
                owner.state.tabId = tabId
                owner.fetchSectionIfNeeded()
            }
            .store(in: &cancellables)

        input.setLocation
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, location: CLLocation) in
                owner.state.location = location
                owner.fetchSectionIfNeeded()
            }
            .store(in: &cancellables)

        input.didTapCategory
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, payload) in
                owner.selectCategory(carouselId: payload.carouselId, categoryId: payload.categoryId)
            }
            .store(in: &cancellables)

        input.didTapCarouselCard
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, payload) in
                guard let card = owner.carouselCard(carouselId: payload.carouselId, cardId: payload.cardId) else { return }
                owner.handleCardTap(card)
            }
            .store(in: &cancellables)

        input.willDisplayCarouselCard
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, payload) in
                guard case .admobCard(let admob) = owner.carouselCard(
                    carouselId: payload.carouselId,
                    cardId: payload.cardId
                ) else { return }
                owner.sendImpressionLogIfNeeded(admob)
            }
            .store(in: &cancellables)

        input.didTapAdmobItem
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, cardId: String) in
                guard let admob = owner.admobItem(cardId: cardId) else { return }
                owner.dependency.logManager.sendEvent(event: ClickEvent(clickLog: admob.clickLog))
            }
            .store(in: &cancellables)

        input.willDisplayAdmobItem
            .withUnretained(self)
            .sink { (owner: HomeCurationViewModel, cardId: String) in
                guard let admob = owner.admobItem(cardId: cardId) else { return }
                owner.sendImpressionLogIfNeeded(admob)
            }
            .store(in: &cancellables)
    }

    private func fetchSectionIfNeeded() {
        guard let tabId = state.tabId, let location = state.location else { return }
        let request = LoadedRequest(
            tabId: tabId,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        guard request != state.loadedRequest else { return }
        state.loadedRequest = request

        loadTask?.cancel()
        cardTasks.values.forEach { $0.cancel() }
        cardTasks = [:]
        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let input = FetchHomeCurationSectionInput(mapLatitude: request.latitude, mapLongitude: request.longitude)
            let result = await dependency.screenRepository.fetchHomeCurationSection(
                curationTabId: request.tabId,
                input: input
            )
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let response):
                applySection(response.items)
            case .failure(let error):
                state.loadedRequest = nil
                guard state.tabId == request.tabId else { return }
                output.route.send(.showErrorAlert(error))
            }
        }
    }

    private func applySection(_ items: [HomeCurationItem]) {
        cardTasks.values.forEach { $0.cancel() }
        cardTasks = [:]
        state.items = items
        state.impressedCardIds = []
        state.selectedCategoryIds = [:]
        state.loadedCategoryIds = [:]
        state.cards = [:]
        for case .carousel(let carousel) in items {
            state.selectedCategoryIds[carousel.carouselId] = carousel.defaultCategoryId
            state.loadedCategoryIds[carousel.carouselId] = carousel.defaultCategoryId
            state.cards[carousel.carouselId] = carousel.cards
        }
        emitItems()
    }

    private func selectCategory(carouselId: String, categoryId: String) {
        guard let carousel = carousel(id: carouselId),
              let filter = carousel.categoryFilters.first(where: { $0.categoryId == categoryId }),
              state.selectedCategoryIds[carouselId] != categoryId,
              let tabId = state.loadedRequest?.tabId,
              let location = state.location else { return }

        dependency.logManager.sendEvent(event: ClickEvent(clickLog: filter.clickLog))

        state.selectedCategoryIds[carouselId] = categoryId
        emitItems()

        cardTasks[carouselId]?.cancel()
        cardTasks[carouselId] = Task { @MainActor [weak self] in
            guard let self else { return }
            let input = FetchHomeCurationCarouselCardsInput(
                categoryId: categoryId,
                mapLatitude: location.coordinate.latitude,
                mapLongitude: location.coordinate.longitude
            )
            let result = await dependency.screenRepository.fetchHomeCurationCarouselCards(
                curationTabId: tabId,
                carouselId: carouselId,
                input: input
            )
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let response):
                state.cards[carouselId] = response.cards
                state.loadedCategoryIds[carouselId] = categoryId
            case .failure:
                state.selectedCategoryIds[carouselId] = state.loadedCategoryIds[carouselId]
            }
            emitItems()
        }
    }

    private func handleCardTap(_ card: HomeCurationCard) {
        switch card {
        case .imagePreviewCard(let preview):
            if let clickLog = preview.clickLog {
                dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
            }
            selectStore(preview)
        case .admobCard(let admob):
            dependency.logManager.sendEvent(event: ClickEvent(clickLog: admob.clickLog))
        }
    }

    private func selectStore(_ card: StoreImagePreviewCard) {
        guard let storeId = storeId(of: card) else {
            routeToLink(of: card)
            return
        }

        storeTask?.cancel()
        storeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let input = FetchStoreInput(storeId: String(storeId), includes: [])
            let result = await dependency.storeRepository.fetchStore(input: input)
            guard !Task.isCancelled else { return }

            guard case .success(let store) = result, let location = store.location else {
                routeToLink(of: card)
                return
            }
            output.didSelectStore.send(HomeCurationSelectedStore(
                storeId: storeId,
                latitude: location.latitude,
                longitude: location.longitude
            ))
        }
    }

    private func routeToLink(of card: StoreImagePreviewCard) {
        guard let link = card.link else { return }
        output.route.send(.deepLink(link))
    }

    private func storeId(of card: StoreImagePreviewCard) -> Int? {
        if let value = card.clickLog?.extraParameters["store_id"]?.anyValue {
            if let storeId = value as? Int { return storeId }
            if let storeId = (value as? String).flatMap(Int.init) { return storeId }
        }
        if let link = card.link?.link,
           let storeId = URLComponents(string: "x://x\(link)")?
            .queryItems?
            .first(where: { $0.name == "storeId" })?
            .value
            .flatMap(Int.init) {
            return storeId
        }
        return card.refs.first.flatMap { Int($0.storeId) }
    }

    private func sendImpressionLogIfNeeded(_ admob: HomeListAdmobCardResponse) {
        guard state.impressedCardIds.insert(admob.cardId).inserted else { return }
        dependency.logManager.sendEvent(event: ImpressionEvent(impressionLog: admob.impressionLog))
    }

    private func emitItems() {
        var seenIds = Set<String>()
        var items: [HomeCurationSectionItem] = []
        for item in state.items {
            switch item {
            case .carousel(let carousel):
                guard seenIds.insert(carousel.carouselId).inserted else { continue }
                let selectedCategoryId = state.selectedCategoryIds[carousel.carouselId] ?? carousel.defaultCategoryId
                items.append(.carousel(HomeCurationCarouselViewData(
                    carouselId: carousel.carouselId,
                    header: carousel.header,
                    categories: carousel.categoryFilters.map {
                        HomeCurationCategoryViewData(filter: $0, isSelected: $0.categoryId == selectedCategoryId)
                    },
                    selectedCategoryId: selectedCategoryId,
                    cards: state.cards[carousel.carouselId] ?? []
                )))
            case .admobCard(let admob):
                guard seenIds.insert(admob.cardId).inserted else { continue }
                items.append(.admobCard(admob))
            }
        }
        output.items.send(items)
    }

    private func carousel(id: String) -> HomeCurationCarousel? {
        for case .carousel(let carousel) in state.items where carousel.carouselId == id {
            return carousel
        }
        return nil
    }

    private func carouselCard(carouselId: String, cardId: String) -> HomeCurationCard? {
        state.cards[carouselId]?.first { $0.cardId == cardId }
    }

    private func admobItem(cardId: String) -> HomeListAdmobCardResponse? {
        for case .admobCard(let admob) in state.items where admob.cardId == cardId {
            return admob
        }
        return nil
    }
}
