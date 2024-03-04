import Combine

import Common
import Model
import Networking
import Log

final class StoreReviewListViewModel: BaseViewModel {
    private static let size: Int = 20
    
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didSelectItem = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let dataSource = CurrentValueSubject<[StoreReviewListSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
        var items: [MyStoreReview] = []
    }

    enum Route {
        case storeDetail(Int)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let reviewService: ReviewServiceProtocol
    private let logManager: LogManagerProtocol

    init(
        reviewService: ReviewServiceProtocol = ReviewService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.reviewService = reviewService
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .merge(with: input.reload)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.nextCursor = nil
                owner.state.hasMore = false
                owner.output.showLoading.send(true)
            })
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.reviewService.fetchMyStoreReview(
                    input:  CursorRequestInput(size: Self.size, cursor: owner.state.nextCursor)
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.items = response.contents.map { MyStoreReview(response: $0) }
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
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
                await owner.reviewService.fetchMyStoreReview(
                    input:  CursorRequestInput(size: Self.size, cursor: owner.state.nextCursor)
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.items.append(contentsOf: response.contents.map { MyStoreReview(response: $0) })
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.didSelectItem
            .withUnretained(self)
            .compactMap { owner, index in
                Int(owner.state.items[safe: index]?.store.id ?? "")
            }
            .map { .storeDetail($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }

    private func updateDataSource() {
        output.dataSource.send([
            StoreReviewListSection(items: state.items.map { .review($0) })
        ])
    }

    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.items.count - 1 && state.hasMore
    }
}
