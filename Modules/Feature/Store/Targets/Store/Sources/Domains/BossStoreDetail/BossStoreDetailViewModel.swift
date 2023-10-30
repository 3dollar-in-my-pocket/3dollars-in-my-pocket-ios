import Foundation
import Combine
import UIKit

import Networking
import Model
import Common
import DependencyInjection
import AppInterface

final class BossStoreDetailViewModel: BaseViewModel {

    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let didTapReviewWriteButton = PassthroughSubject<Void, Never>()

        // Overview section
        let didTapSave = PassthroughSubject<Void, Never>()
        let didTapShare = PassthroughSubject<Void, Never>()
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapNavigationAction = PassthroughSubject<NavigationAppType, Never>()
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
        let didTapAddress = PassthroughSubject<Void, Never>()
        let didTapMapDetail = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let dataSource = CurrentValueSubject<[BossStoreDetailSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
        let isHiddenClosedStoreButton = CurrentValueSubject<Bool, Never>(true)

        // Overview section
        let isFavorited = PassthroughSubject<Bool, Never>()
        let subscribersCount = PassthroughSubject<Int, Never>()

        let updateHeight = PassthroughSubject<Void, Never>()
    }

    struct State {
        var storeDetailData: BossStoreDetailData?
    }

    enum Route {
        case openUrl(URL)
        case presentNavigation
        case presentMapDetail(MapDetailViewModel)
        case presentFeedback(BossStoreFeedbackViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let storeService: StoreServiceProtocol
    private let userDefaults: UserDefaultsUtil

    private let storeId: String

    init(
        storeId: String,
        storeService: StoreServiceProtocol = StoreService(),
        userDefaults: UserDefaultsUtil = .shared
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.userDefaults = userDefaults

        super.init()

        bindOverviewSection()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .merge(with: input.reload)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                let input = FetchBossStoreDetailInput(
                    storeId: owner.storeId,
                    latitude: owner.userDefaults.userCurrentLocation.coordinate.latitude,
                    longitude: owner.userDefaults.userCurrentLocation.coordinate.longitude
                )

                return await owner.storeService.fetchBossStoreDetail(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.storeDetailData = BossStoreDetailData(response: response)
                    owner.output.isHiddenClosedStoreButton.send(response.openStatus.status == .open)
                    owner.reloadDataSource()
                case .failure(let error):
                    owner.output.toast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

        input.didTapReviewWriteButton
            .withUnretained(self)
            .map { owner, _ in
                owner.bindFeedbackViewModel(
                    with: owner.state.storeDetailData?.feedbacks.map { $0.feedbackType }.compactMap { $0 } ?? []
                )
            }
            .map { .presentFeedback($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }

    private func bindOverviewSection() {
        input.didTapSave
            .withUnretained(self)
            .sink { owner, _ in
                let isDeleted = owner.state.storeDetailData?.overview.isFavorited == true
                owner.saveStore(isDelete: isDeleted)
            }
            .store(in: &cancellables)

        input.didTapShare
            .withUnretained(self)
            .sink { owner, _ in
                owner.shareKakao()
            }
            .store(in: &cancellables)

        input.didTapNavigation
            .map { .presentNavigation }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didTapNavigationAction
            .withUnretained(self)
            .sink { owner, type in
                owner.goToNavigationApplication(type: type)
            }
            .store(in: &cancellables)

        input.didTapSnsButton
            .withUnretained(self)
            .compactMap { owner, _ in
                if let snsUrl = owner.state.storeDetailData?.overview.snsUrl {
                    return URL(string: snsUrl)
                }
                return nil
            }
            .map { .openUrl($0) }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didTapAddress
            .withUnretained(self)
            .sink { owner, _ in
                owner.copyAddressToClipBoard()
            }
            .store(in: &cancellables)

        input.didTapMapDetail
            .withUnretained(self)
            .sink { owner, _ in
                owner.presentMapDetail()
            }
            .store(in: &cancellables)
    }

    private func reloadDataSource() {
        guard let storeDetailData = state.storeDetailData else { return }

        var infoItems: [BossStoreDetailSectionItem] = [.info(BossStoreInfoCellViewModel(data: storeDetailData))]
        if storeDetailData.store.menus.isEmpty {
            infoItems.append(.emptyMenu)
        } else {
            infoItems.append(.menuList(bindMenuListCellViewModel(with: storeDetailData)))
        }

        output.dataSource.send([
            .init(type: .overview, items: [.overview(bindOverviewCellViewModel(storeDetailData.overview))]),
            .init(type: .info, items: infoItems),
            .init(type: .workday, items: [.workday(storeDetailData.workdays)]),
            .init(type: .feedbacks, items: [.feedbacks(bindFeedbacksCellViewModel(with: storeDetailData.feedbacks))])
        ])
    }

    private func bindOverviewCellViewModel(_ data: StoreDetailOverview) -> StoreDetailOverviewCellViewModel {
        let config = StoreDetailOverviewCellViewModel.Config(overview: data)
        let viewModel = StoreDetailOverviewCellViewModel(config: config)

        viewModel.output.didTapFavorite
            .subscribe(input.didTapSave)
            .store(in: &cancellables)

        viewModel.output.didTapShare
            .subscribe(input.didTapShare)
            .store(in: &cancellables)

        viewModel.output.didTapNavigation
            .subscribe(input.didTapNavigation)
            .store(in: &cancellables)

        viewModel.output.didTapSnsButton
            .subscribe(input.didTapSnsButton)
            .store(in: &cancellables)

        viewModel.output.didTapAddress
            .subscribe(input.didTapAddress)
            .store(in: &cancellables)

        viewModel.output.didTapMapDetail
            .subscribe(input.didTapMapDetail)
            .store(in: &cancellables)

        output.isFavorited
            .subscribe(viewModel.input.isFavorited)
            .store(in: &cancellables)

        output.subscribersCount
            .subscribe(viewModel.input.subscribersCount)
            .store(in: &cancellables)

        return viewModel
    }

    private func bindFeedbacksCellViewModel(with data: [FeedbackCountWithRatioResponse]) -> BossStoreFeedbacksCellViewModel {
        let cellViewModel = BossStoreFeedbacksCellViewModel(data: data)
        return cellViewModel
    }

    private func saveStore(isDelete: Bool) {
        Task {
            let saveResult = await storeService.saveStore(
                storeType: .bossStore,
                storeId: storeId,
                isDelete: isDelete
            )

            switch saveResult {
            case .success(_):
                if isDelete {
                    state.storeDetailData?.overview.isFavorited = false
                    state.storeDetailData?.overview.subscribersCount -= 1
                    output.isFavorited.send(false)
                    output.toast.send(Strings.StoreDetail.Toast.removeFavorite)
                } else {
                    state.storeDetailData?.overview.isFavorited = true
                    state.storeDetailData?.overview.subscribersCount += 1
                    output.isFavorited.send(true)
                    output.toast.send(Strings.StoreDetail.Toast.addFavorite)
                }
                output.subscribersCount.send(state.storeDetailData?.overview.subscribersCount ?? 0)

            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func shareKakao() {
        guard let appInterface = DIContainer.shared.container.resolve(AppModuleInterface.self),
              let overview = state.storeDetailData?.overview, let storeIdInt = Int(storeId) else { return }

        appInterface.shareKakao(storeId: storeIdInt, storeDetailOverview: overview)
    }

    private func goToNavigationApplication(type: NavigationAppType) {
        guard let storeDetailData = state.storeDetailData,
              let appInfomation = DIContainer.shared.container.resolve(AppInfomation.self) else { return }
        let location = storeDetailData.overview.location
        let storeName = storeDetailData.overview.storeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlScheme: String
        switch type {
        case .kakao:
            urlScheme = "kakaomap://look?p=\(location.latitude),\(location.longitude)"

        case .naver:
            urlScheme = "nmap://place?lat=\(location.latitude)&lng=\(location.longitude)&name=\(storeName)&zoom=20&appname=\(appInfomation.bundleId)"
        }

        guard let url = URL(string: urlScheme) else { return }
        UIApplication.shared.open(url)
    }

    private func copyAddressToClipBoard() {
        guard let address = state.storeDetailData?.overview.address else { return }
        UIPasteboard.general.string = address

        output.toast.send(Strings.StoreDetail.Toast.copyToAddress)
    }

    private func presentMapDetail() {
        guard let storeDetailData = state.storeDetailData else { return }
        let config = MapDetailViewModel.Config(
            location: storeDetailData.overview.location,
            storeName: storeDetailData.overview.storeName
        )
        let viewModel = MapDetailViewModel(config: config)

        output.route.send(.presentMapDetail(viewModel))
    }

    private func bindFeedbackViewModel(with data: [FeedbackType]) -> BossStoreFeedbackViewModel {
        let viewModel = BossStoreFeedbackViewModel(storeId: storeId, feedbackTypes: data)
        
        viewModel.output.sendFeedbacks
            .subscribe(input.reload)
            .store(in: &cancellables)

        return viewModel
    }

    private func bindMenuListCellViewModel(with data: BossStoreDetailData) -> BossStoreMenuListCellViewModel {
        let cellViewModel = BossStoreMenuListCellViewModel(data: data)

        cellViewModel.output.updateHeight
            .subscribe(output.updateHeight)
            .store(in: &cancellables)

        return cellViewModel
    }
}
