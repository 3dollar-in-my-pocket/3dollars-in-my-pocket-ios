import Combine

import Common
import Model
import Networking
import Log
import StoreInterface

final class CouponListViewModel: BaseViewModel {
    private static let size: Int = 20
    
    struct Config {
        let statuses: [GetMyIssuedCouponsInput.Status]
    }
    
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didSelectItem = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .myReview
        let dataSource = CurrentValueSubject<[CouponListSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let reload = PassthroughSubject<Void, Never>()
    }

    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
        var items: [StoreCouponSimpleResponse] = []
    }

    enum Route {
        case presentUseCoupon(BossStoreCouponBottomSheetViewModel)
        case bossStoreDetail(String)
    }

    let input = Input()
    let output = Output()

    private let config: Config
    private var state = State()
    private let couponRepository: CouponRepository
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        couponRepository: CouponRepository = CouponRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.couponRepository = couponRepository
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .merge(with: output.reload)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.nextCursor = nil
                owner.state.hasMore = false
                owner.output.showLoading.send(true)
            })
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.couponRepository.getMyIssuedCoupons(
                    input:  GetMyIssuedCouponsInput(cursor: owner.state.nextCursor, size: Self.size, statuses: owner.config.statuses)
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.items = response.contents
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
                await owner.couponRepository.getMyIssuedCoupons(
                    input:  GetMyIssuedCouponsInput(cursor: owner.state.nextCursor, size: Self.size, statuses: owner.config.statuses)
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.items.append(contentsOf: response.contents)
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
    }

    private func updateDataSource() {
        output.dataSource.send([
            CouponListSection(items: state.items.map { .coupon(bindCouponCellViewModel($0)) })
        ])
    }
    
    private func bindCouponCellViewModel(_ coupon: StoreCouponSimpleResponse) -> BossStoreCouponViewModel {
        let config = BossStoreCouponViewModel.Config(storeId: "", data: coupon, sourceType: .myCoupons)
        let viewModel = BossStoreCouponViewModel(config: config)
        
        viewModel.output.showLoading
            .subscribe(output.showLoading)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.showToast
            .subscribe(output.showToast)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.moveToUseCoupon
            .withUnretained(self)
            .map { owner, coupon in
                let viewModel = owner.bindStoreCouponBottomSheetViewModel(coupon)
                return .presentUseCoupon(viewModel)
            }
            .subscribe(output.route)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.moveToStoreDetail
            .withUnretained(self)
            .map { owner, storeId in
                return .bossStoreDetail(storeId)
            }
            .subscribe(output.route)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
    
    private func bindStoreCouponBottomSheetViewModel(_ data: StoreCouponSimpleResponse) -> BossStoreCouponBottomSheetViewModel {
        let config = BossStoreCouponBottomSheetViewModel.Config(storeId: "", coupon: data)
        let viewModel = BossStoreCouponBottomSheetViewModel(config: config)
        
        viewModel.output.reloadCouponList
            .subscribe(output.reload)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }

    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.items.count - 1 && state.hasMore
    }
}
