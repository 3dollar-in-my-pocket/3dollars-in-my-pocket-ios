import Foundation
import Combine
import UIKit

import Networking
import Model
import Common
import DependencyInjection
import AppInterface
import Log

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
        
        // Info Section
        let didTapPhoto = PassthroughSubject<Int, Never>()
        
        // Post Section
        let didTapMorePost = PassthroughSubject<Void, Never>()
        let didTapPostPhoto = PassthroughSubject<Int, Never>()
        
        // 리뷰 섹션
        let didTapReviewRightButton = PassthroughSubject<Int, Never>()
        let didTapReviewLikeButton = PassthroughSubject<Int, Never>()
        let onSuccessEditReview = PassthroughSubject<StoreReviewResponse, Never>()
        let didTapReviewMore = PassthroughSubject<Void, Never>()
        let onSuccessReportReview = PassthroughSubject<Int, Never>()
        let updateReview = PassthroughSubject<StoreDetailReview, Never>()
    }

    struct Output {
        let screenName: ScreenName = .bossStoreDetail
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
        case pushPostList(BossStorePostListViewModel)
        case presentBossPhotoDetail(BossStorePhotoViewModel)
        case navigateAppleMap(LocationResponse)
        case showErrorAlert(Error)
        case presentReviewWrite(ReviewWriteViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let storeService: StoreRepository
    private let preference = Preference.shared
    private let logManager: LogManagerProtocol

    private let storeId: String

    init(
        storeId: String,
        storeService: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.logManager = logManager

        super.init()

        bindOverviewSection()
        bindInfoSection()
        bindPostSection()
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
                    latitude: owner.preference.userCurrentLocation.coordinate.latitude,
                    longitude: owner.preference.userCurrentLocation.coordinate.longitude
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
                    owner.output.isFavorited.send(response.favorite.isFavorite)
                    owner.reloadDataSource()
                case .failure(let error):
                    owner.output.toast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

        input.didTapReviewWriteButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: BossStoreDetailViewModel, _) in
                owner.sendClickLog(eventName: .clickWriteReview)
            })
            .map { owner, _ in
                owner.bindReviewWriteViewModel()
            }
            .map { .presentReviewWrite($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }

    private func bindOverviewSection() {
        input.didTapSave
            .withUnretained(self)
            .sink { owner, _ in
                let isDeleted = owner.state.storeDetailData?.overview.isFavorited == true
                owner.saveStore(isDelete: isDeleted)
                owner.sendClickFavoriteLog(isDelete: isDeleted)
            }
            .store(in: &cancellables)

        input.didTapShare
            .withUnretained(self)
            .sink { owner, _ in
                owner.shareKakao()
                owner.sendClickLog(eventName: .clickShare)
            }
            .store(in: &cancellables)

        input.didTapNavigation
            .handleEvents(receiveOutput: { [weak self] in
                self?.sendClickLog(eventName: .clickNavigation)
            })
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
            .handleEvents(receiveOutput: { (owner: BossStoreDetailViewModel, _) in
                owner.sendClickLog(eventName: .clickSns)
            })
            .compactMap { owner, _ in
                if let snsUrl = owner.state.storeDetailData?.overview.snsUrl {
                    return URL(string: snsUrl)
                } else {
                    owner.output.toast.send(Strings.BossStoreDetail.Sns.empty)
                    return nil
                }
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
    
    private func bindInfoSection() {
        input.didTapPhoto
            .withUnretained(self)
            .sink { (owner: BossStoreDetailViewModel, index: Int) in
                owner.presentBossPhoto(index: index)
            }
            .store(in: &cancellables)
    }
    
    private func bindPostSection() {
        input.didTapMorePost
            .withUnretained(self)
            .sink { (owner: BossStoreDetailViewModel, _) in
                owner.pushPostList()
            }
            .store(in: &cancellables)
        
        input.didTapPostPhoto
            .withUnretained(self)
            .sink { (owner: BossStoreDetailViewModel, selectedIndex: Int) in
                owner.presentBossPostPhoto(index: selectedIndex)
            }
            .store(in: &cancellables)
    }

    private func reloadDataSource() {
        guard let storeDetailData = state.storeDetailData else { return }

        var infoItems: [BossStoreDetailSectionItem] = [.info(bindInfoCellViewModel(storeDetailData.info))]
        if storeDetailData.store.menus.isEmpty {
            infoItems.append(.emptyMenu)
        } else {
            infoItems.append(.menuList(bindMenuListCellViewModel(with: storeDetailData.menus)))
        }
        
        var sections: [BossStoreDetailSection] = [
            .init(type: .overview, items: [.overview(bindOverviewCellViewModel(storeDetailData.overview))]),
            .init(type: .info, items: infoItems)
        ]
        
        if let post = storeDetailData.post,
           let totalPostCount = storeDetailData.totalPostCount {
            let cellViewModel = bindPostCellViewModel(store: storeDetailData.store, post: post, totalCount: totalPostCount)
            sections.append(.init(type: .post, items: [.post(cellViewModel)]))
        }
        
        sections.append(contentsOf: [
            .init(type: .workday, items: [.workday(storeDetailData.workdays)])
        ])
        
        if let reviewSection = createReviewSection() {
            sections.append(reviewSection)
        }

        output.dataSource.send(sections)
    }
    
    private func bindInfoCellViewModel(_ info: BossStoreInfo) -> BossStoreInfoCellViewModel {
        let config = BossStoreInfoCellViewModel.Config(screenName: output.screenName, storeId: storeId, info: info)
        let viewModel = BossStoreInfoCellViewModel(config: config)
        
        viewModel.output.didTapSnsButton
            .subscribe(input.didTapSnsButton)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.didTapPhoto
            .subscribe(input.didTapPhoto)
            .store(in: &viewModel.cancellables)
        return viewModel
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
        
        cellViewModel.output.didTapSendFeedbackButton
            .subscribe(input.didTapReviewWriteButton)
            .store(in: &cancellables)

        return cellViewModel
    }

    private func saveStore(isDelete: Bool) {
        Task {
            let saveResult = await storeService.saveStore(storeId: storeId, isDelete: isDelete)

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

        appInterface.shareKakao(storeId: storeIdInt, storeType: .bossStore, storeDetailOverview: overview)
    }

    private func goToNavigationApplication(type: NavigationAppType) {
        guard let storeDetailData = state.storeDetailData,
              let appInfomation = DIContainer.shared.container.resolve(AppInformation.self) else { return }
        let location = storeDetailData.overview.location
        let storeName = storeDetailData.overview.storeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlScheme: String
        switch type {
        case .kakao:
            urlScheme = "kakaomap://look?p=\(location?.latitude ?? 0),\(location?.longitude ?? 0)"
            guard let url = URL(string: urlScheme) else { return }
            UIApplication.shared.open(url)
        case .naver:
            urlScheme = "nmap://place?lat=\(location?.latitude ?? 0)&lng=\(location?.longitude ?? 0)&name=\(storeName)&zoom=20&appname=\(appInfomation.bundleId)"
            guard let url = URL(string: urlScheme) else { return }
            UIApplication.shared.open(url)
        case .apple:
            guard let location else { return }
            output.route.send(.navigateAppleMap(location))
        }
    }

    private func copyAddressToClipBoard() {
        guard let address = state.storeDetailData?.overview.address else { return }
        UIPasteboard.general.string = address

        output.toast.send(Strings.StoreDetail.Toast.copyToAddress)
    }

    private func presentMapDetail() {
        guard let storeDetailData = state.storeDetailData,
              let location = storeDetailData.overview.location else { return }
        let config = MapDetailViewModel.Config(
            location: location,
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

    private func bindMenuListCellViewModel(with menus: [BossStoreMenu]) -> BossStoreMenuListCellViewModel {
        let cellViewModel = BossStoreMenuListCellViewModel(menus: menus)

        cellViewModel.output.updateHeight
            .subscribe(output.updateHeight)
            .store(in: &cancellables)

        return cellViewModel
    }
    
    private func bindPostCellViewModel(
        store: BossStoreResponse,
        post: PostResponse,
        totalCount: Int
    ) -> BossStorePostCellViewModel {
        let config = BossStorePostCellViewModel.Config(store: store, post: post, totalCount: totalCount)
        let cellViewModel = BossStorePostCellViewModel(config: config)
        
        cellViewModel.output.didTapMore
            .subscribe(input.didTapMorePost)
            .store(in: &cellViewModel.cancellables)
        
        cellViewModel.output.expendContent.dropFirst()
            .mapVoid
            .subscribe(output.updateHeight)
            .store(in: &cellViewModel.cancellables)
       
        cellViewModel.output.didTapPhoto
            .subscribe(input.didTapPostPhoto)
            .store(in: &cellViewModel.cancellables)
        
        cellViewModel.output.showErrorAlert
            .map { Route.showErrorAlert($0) }
            .subscribe(output.route)
            .store(in: &cellViewModel.cancellables)
        
        return cellViewModel
    }
    
    private func presentBossPhoto(index: Int) {
        guard let store = state.storeDetailData?.store else { return }
        let config = BossStorePhotoViewModel.Config(photos: store.representativeImages, selectedIndex: index)
        let viewModel = BossStorePhotoViewModel(config: config)
        
        output.route.send(.presentBossPhotoDetail(viewModel))
    }
    
    private func presentBossPostPhoto(index: Int) {
        guard let post = state.storeDetailData?.post else { return }
        let photos = post.sections.map { ImageResponse(imageUrl: $0.url) }
        let config = BossStorePhotoViewModel.Config(photos: photos, selectedIndex: index)
        let viewModel = BossStorePhotoViewModel(config: config)
        
        output.route.send(.presentBossPhotoDetail(viewModel))
    }
    
    private func pushPostList() {
        let config = BossStorePostListViewModel.Config(storeId: storeId)
        let viewModel = BossStorePostListViewModel(config: config)
        
        output.route.send(.pushPostList(viewModel))
    }
}
                                    
// MARK: - Review Section
extension BossStoreDetailViewModel {
    private func createReviewSection() -> BossStoreDetailSection? {
        guard let storeDetailData = state.storeDetailData else { return nil }
        
        var reviewSectionItems: [BossStoreDetailSectionItem] = []
        
        let header = StoreDetailSectionHeader(
            title: Strings.StoreDetail.Review.Header.title,
            description: nil,
            value: " \(storeDetailData.totalReviewCount)개",
            buttonTitle: Strings.StoreDetail.Review.Header.button
        )
        
        if storeDetailData.reviews.isEmpty {
            reviewSectionItems.append(.reviewRating(rating: 0.0))
            reviewSectionItems.append(.reviewFeedbackSummary(bindReviewFeedbackSummaryCellViewModel(with: storeDetailData.feedbacks)))
            reviewSectionItems.append(.reviewEmpty)
        } else {
            reviewSectionItems.append(.reviewRating(rating: storeDetailData.store.rating))
            reviewSectionItems.append(.reviewFeedbackSummary(bindReviewFeedbackSummaryCellViewModel(with: storeDetailData.feedbacks)))
            reviewSectionItems.append(contentsOf: storeDetailData.reviews.prefix(3).map {
                .review(bindReviewCellViewModel(with: $0))
            })
            if storeDetailData.totalReviewCount > 3 {
                reviewSectionItems.append(.reviewMore(totalCount: storeDetailData.totalReviewCount))
            }
        }
        
        return BossStoreDetailSection(type: .review, header: header, items: reviewSectionItems)
    }
    
    private func bindReviewFeedbackSummaryCellViewModel(with data: [FeedbackCountWithRatioResponse]) -> BossStoreDetailReviewFeedbackSummaryCellViewModel {
        let viewModel = BossStoreDetailReviewFeedbackSummaryCellViewModel(data: data)
        
        // TODO: 수정 필요
        viewModel.output.moveToFeedbackList
            .compactMap { [weak self] in
                guard let self else { return nil }
                
                return .presentFeedback(bindFeedbackViewModel(
                    with: state.storeDetailData?.feedbacks.map { $0.feedbackType }.compactMap { $0 } ?? []
                ))
            }
            .subscribe(output.route)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
    
    private func bindReviewCellViewModel(with data: StoreDetailReview) -> BossStoreDetailReviewCellViewModel {
        let viewModel = BossStoreDetailReviewCellViewModel(data: data)
        return viewModel
    }
    
    private func bindReviewWriteViewModel() -> ReviewWriteViewModel {
        let viewModel = ReviewWriteViewModel(config: .init(
            storeId: storeId,
            feedbackTypes: state.storeDetailData?.feedbacks.map { $0.feedbackType }.compactMap { $0 } ?? []
        ))
        
        viewModel.output.onSuccessWriteReview
            .mapVoid
            .subscribe(input.reload)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
}

extension BossStoreDetailViewModel {
    private func sendClickFavoriteLog(isDelete: Bool) {
        let value = isDelete ? "off" : "on"
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickFavorite,
            extraParameters: [
                .storeId: storeId,
                .value: value
            ]
        ))
    }
    
    private func sendClickLog(eventName: EventName) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: eventName,
            extraParameters: [.storeId: storeId]))
    }
}
