import UIKit
import Combine

import Common
import Networking
import Model
import DependencyInjection
import AppInterface
import Log

final class StoreDetailViewModel: BaseViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
        let didTapVisit = PassthroughSubject<Void, Never>()
        
        // Report modal
        let dismissReportModal = PassthroughSubject<Void, Never>()
        
        // Overview section
        let didTapSave = PassthroughSubject<Void, Never>()
        let didTapShare = PassthroughSubject<Void, Never>()
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapNavigationAction = PassthroughSubject<NavigationAppType, Never>()
        let didTapWriteReview = PassthroughSubject<Void, Never>()
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
        let didTapAddress = PassthroughSubject<Void, Never>()
        let didTapMapDetail = PassthroughSubject<Void, Never>()
        
        // 가게 정보 메뉴 섹션
        let didTapShowMoreMenu = PassthroughSubject<Void, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
        
        // 사진 섹션
        let didTapUploadPhoto = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let onSuccessUploadPhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
        let onSuccessUpdatePhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
        
        // 리뷰 섹션
        let didTapReviewRightButton = PassthroughSubject<Int, Never>()
        let onSuccessEditReview = PassthroughSubject<StoreReviewResponse, Never>()
        let didTapReviewMore = PassthroughSubject<Void, Never>()
        let onSuccessReportReview = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .storeDetail
        let sections = PassthroughSubject<[StoreDetailSection], Never>()
        
        // Overview section
        let isFavorited = PassthroughSubject<Bool, Never>()
        let subscribersCount = PassthroughSubject<Int, Never>()
        
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
    }
    
    struct State {
        let storeId: Int
        let storeType: StoreType = .userStore
        var storeDetailData: StoreDetailData?
        var showAllMenu: Bool = false
    }
    
    enum Route {
        case dismissReportModalAndPop
        case presentReport(ReportBottomSheetViewModel)
        case presentNavigation
        case presentWriteReview(ReviewBottomSheetViewModel)
        case presentMapDetail(MapDetailViewModel)
        case pushEditStore(storeId: Int, storeDetailData: StoreDetailData)
        case presentUploadPhoto(UploadPhotoViewModel)
        case pushPhotoList(PhotoListViewModel)
        case presentPhotoDetail(PhotoDetailViewModel)
        case pushReviewList(ReviewListViewModel)
        case presentReportBottomSheetReview(ReportReviewBottomSheetViewModel)
        case presentVisit(VisitViewModel)
    }
    
    let input = Input()
    let output = Output()
    var state: State
    private let storeService: StoreServiceProtocol
    private let reportService: ReportServiceProtocol
    private let userDefaults: UserDefaultsUtil
    private let logManager: LogManagerProtocol
    
    init(
        storeId: Int,
        storeService: StoreServiceProtocol = StoreService(),
        reportService: ReportServiceProtocol = ReportService(),
        userDefaults: UserDefaultsUtil = .shared,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.state = State(storeId: storeId)
        self.storeService = storeService
        self.reportService = reportService
        self.userDefaults = userDefaults
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        bindOverviewSection()
        bindInfoSection()
        bindPhotoSection()
        bindReviewSection()
        
        input.load
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _: Void) in
                owner.fetchStoreDetail()
            }
            .store(in: &cancellables)
        
        input.dismissReportModal
            .map { Route.dismissReportModalAndPop }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapReport
            .withUnretained(self)
            .sink(receiveValue: { (owner: StoreDetailViewModel, _) in
                owner.presentReportModal()
                owner.sendClickEvent(.clickReport)
            })
            .store(in: &cancellables)
        
        input.didTapVisit
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.presentVisit()
                owner.sendClickEvent(.clickVisit)
            }
            .store(in: &cancellables)
    }
    
    private func bindOverviewSection() {
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                let isDeleted = owner.state.storeDetailData?.overview.isFavorited == true
                owner.saveStore(isDelete: isDeleted)
                owner.sendClickSaveLog(isDelete: isDeleted)
            }
            .store(in: &cancellables)
        
        input.didTapShare
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.shareKakao()
                owner.sendClickEvent(.clickShare)
            }
            .store(in: &cancellables)
        
        input.didTapNavigation
            .handleEvents(receiveOutput: { [weak self] in
                self?.sendClickEvent(.clickNavigation)
            })
            .map { Route.presentNavigation }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapNavigationAction
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, type: NavigationAppType) in
                owner.goToNavigationApplication(type: type)
            }
            .store(in: &cancellables)
        
        input.didTapWriteReview
            .withUnretained(self)
            .sink(receiveValue: { (owner: StoreDetailViewModel, _) in
                owner.presentWriteReviewBottomSheet()
                owner.sendClickEvent(.clickWriteReview)
            })
            .store(in: &cancellables)
        
        input.onSuccessWriteReview
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, review) in
                owner.state.storeDetailData?.reviews.insert(review, at: 0)
                owner.state.storeDetailData?.totalReviewCount += 1
                owner.refreshSections()
            }
            .store(in: &cancellables)
        
        input.didTapAddress
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.copyAddressToClipBoard()
                owner.sendClickEvent(.clickCopyAddress)
            }
            .store(in: &cancellables)
        
        input.didTapMapDetail
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.presentMapDetail()
                owner.sendClickEvent(.clickZoomMap)
            }
            .store(in: &cancellables)
    }
    
    private func bindInfoSection() {
        input.didTapShowMoreMenu
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.state.showAllMenu = true
                owner.refreshSections()
            }
            .store(in: &cancellables)
        
        input.didTapEdit
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.pushEditStore()
            }
            .store(in: &cancellables)
    }
    
    private func bindPhotoSection() {
        input.didTapUploadPhoto
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.presentUploadPhoto()
            }
            .store(in: &cancellables)
        
        input.onSuccessUploadPhotos
            .mapVoid
            .subscribe(input.load)
            .store(in: &cancellables)
        
        input.didTapPhoto
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, index: Int) in
                let photoCount = owner.state.storeDetailData?.photos.count ?? 0
                if index == 3 && photoCount > 4 {
                    owner.pushPhotoList()
                } else {
                    owner.presentPhotoDetail(index: index)
                }
            }
            .store(in: &cancellables)
        
        input.onSuccessUpdatePhotos
            .mapVoid
            .subscribe(input.load)
            .store(in: &cancellables)
    }
    
    private func bindReviewSection() {
        input.didTapReviewRightButton
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, index: Int) in
                guard let review = owner.state.storeDetailData?.reviews[safe: index] else { return }
                
                if review.isOwner {
                    owner.presentEditReviewBottomSheet(review: review)
                } else {
                    owner.presentReportReviewBottomSheet(review: review)
                }
            }
            .store(in: &cancellables)
        
        input.onSuccessEditReview
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, response: StoreReviewResponse) in
                guard let targetIndex = owner.state.storeDetailData?.reviews.firstIndex(where: {
                    $0.reviewId == response.reviewId
                }) else { return }
                
                owner.state.storeDetailData?.reviews[targetIndex].rating = response.rating
                owner.state.storeDetailData?.reviews[targetIndex].contents = response.contents
                owner.refreshSections()
            }
            .store(in: &cancellables)
        
        input.didTapReviewMore
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.pushReviewList()
            }
            .store(in: &cancellables)
        
        input.onSuccessReportReview
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, reviewId: Int) in
                guard let targetIndex = owner.state.storeDetailData?.reviews.firstIndex(where: { $0.reviewId == reviewId }) else { return }
                
                owner.state.storeDetailData?.reviews[targetIndex].isFiltered = true
                owner.refreshSections()
            }
            .store(in: &cancellables)
    }
    
    private func fetchStoreDetail() {
        Task { [weak self] in
            guard let self else { return }
            
            let input = FetchStoreDetailInput(
                storeId: state.storeId,
                latitude: userDefaults.userCurrentLocation.coordinate.latitude,
                longitude: userDefaults.userCurrentLocation.coordinate.longitude
            )
            let storeDetailResult = await storeService.fetchStoreDetail(input: input)
            
            switch storeDetailResult {
            case .success(let response):
                let storeDetailData = StoreDetailData(
                    response: response,
                    totalPhotoCount: response.images.cursor.totalCount,
                    totalReviewCount: response.reviews.cursor.totalCount
                )
                
                state.storeDetailData = storeDetailData
                refreshSections()
                output.isFavorited.send(response.favorite.isFavorite)
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func refreshSections() {
        guard let storeDetailData = state.storeDetailData else { return }
        
        output.sections.send([
            .overviewSection(createOverviewCellViewModel(storeDetailData.overview)),
            .visitSection(storeDetailData.visit),
            .infoSection(
                updatedAt: DateUtils.toString(dateString: storeDetailData.info.lastUpdated, format: "yyyy.MM.dd 업데이트"),
                info: storeDetailData.info,
                menuCellViewModel: createMenuCellViewModel(storeDetailData)
            ),
            .photoSection(totalCount: storeDetailData.totalPhotoCount, photos: storeDetailData.photos),
            .reviewSection(
                totalCount: storeDetailData.totalReviewCount,
                rating: storeDetailData.rating,
                reviews: storeDetailData.reviews
            )
        ])
    }
    
    private func createOverviewCellViewModel(_ data: StoreDetailOverview) -> StoreDetailOverviewCellViewModel {
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
        
        viewModel.output.didTapWriteReview
            .subscribe(input.didTapWriteReview)
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
    
    private func createMenuCellViewModel(_ data: StoreDetailData) -> StoreDetailMenuCellViewModel {
        let config = StoreDetailMenuCellViewModel.Config(menus: data.menus, isShowAll: state.showAllMenu)
        let viewModel = StoreDetailMenuCellViewModel(config: config)
        
        viewModel.output.didTapMore
            .subscribe(input.didTapShowMoreMenu)
            .store(in: &cancellables)
        
        return viewModel
    }
    
    private func saveStore(isDelete: Bool) {
        Task {
            let saveResult = await storeService.saveStore(
                storeType: state.storeType,
                storeId: String(state.storeId),
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
    
    private func presentReportModal() {
        Task {
            let reportReasonResult = await reportService.fetchReportReasons(group: .store)
                .map { response in
                    response.reasons.map { ReportReason(response: $0) }
                }
            
            switch reportReasonResult {
            case .success(let reasons):
                let viewModel = createReportModalViewModel(reasons: reasons)
                output.route.send(Route.presentReport(viewModel))
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func createReportModalViewModel(reasons: [ReportReason]) -> ReportBottomSheetViewModel {
        let config = ReportBottomSheetViewModel.Config(storeId: state.storeId, reportReasons: reasons)
        let viewModel = ReportBottomSheetViewModel(config: config)
        
        viewModel.output.dismissWithPop
            .subscribe(input.dismissReportModal)
            .store(in: &viewModel.cancellables)
        
        return viewModel
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
    
    private func shareKakao() {
        guard let appInterface = DIContainer.shared.container.resolve(AppModuleInterface.self),
              let overview = state.storeDetailData?.overview else { return }
        
        appInterface.shareKakao(storeId: state.storeId, storeType: .userStore, storeDetailOverview: overview)
    }
    
    private func presentWriteReviewBottomSheet() {
        let config = ReviewBottomSheetViewModel.Config(storeId: state.storeId, review: nil)
        let viewModel = ReviewBottomSheetViewModel(config: config)
        
        viewModel.output.onSuccessWriteReview
            .mapVoid
            .subscribe(input.load)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentWriteReview(viewModel))
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
    
    private func presentUploadPhoto() {
        let config = UploadPhotoViewModel.Config(storeId: state.storeId)
        let viewModel = UploadPhotoViewModel(config: config)
        
        viewModel.output.onSuccessUploadPhotos
            .subscribe(input.onSuccessUploadPhotos)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentUploadPhoto(viewModel))
    }
    
    private func pushPhotoList() {
        let config = PhotoListViewModel.Config(storeId: state.storeId)
        let viewModel = PhotoListViewModel(config: config)
        
        viewModel.output.onSuccessUploadPhotos
            .subscribe(input.onSuccessUploadPhotos)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.pushPhotoList(viewModel))
    }
    
    private func presentPhotoDetail(index: Int) {
        let config = PhotoDetailViewModel.Config(storeId: state.storeId, hasMore: true, currentIndex: index)
        let viewModel = PhotoDetailViewModel(config: config)
        
        viewModel.output.updatePhotoListState
            .map { $0.photos }
            .subscribe(input.onSuccessUpdatePhotos)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentPhotoDetail(viewModel))
    }
    
    private func presentEditReviewBottomSheet(review: StoreDetailReview) {
        let config = ReviewBottomSheetViewModel.Config(storeId: state.storeId, review: review)
        let viewModel = ReviewBottomSheetViewModel(config: config)
        
        viewModel.output.onSuccessEditReview
            .subscribe(input.onSuccessEditReview)
            .store(in: &viewModel.cancellables)
        output.route.send(.presentWriteReview(viewModel))
    }
    
    private func pushReviewList() {
        let config = ReviewListViewModel.Config(storeId: state.storeId)
        let viewModel = ReviewListViewModel(config: config)
        
        viewModel.output.onSuccessEditReview
            .subscribe(input.onSuccessEditReview)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onSuccessWriteReview
            .subscribe(input.onSuccessWriteReview)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onSuccessReportReview
            .subscribe(input.onSuccessReportReview)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.pushReviewList(viewModel))
    }
    
    private func presentReportReviewBottomSheet(review: StoreDetailReview) {
        Task {
            let reportReasonResult = await reportService.fetchReportReasons(group: .review)
                .map { response in
                    response.reasons.map { ReportReason(response: $0) }
                }
            
            switch reportReasonResult {
            case .success(let reasons):
                let viewModel = createReportReviewBottomSheetViewModel(review: review, reasons: reasons)
                
                output.route.send(.presentReportBottomSheetReview(viewModel))
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func createReportReviewBottomSheetViewModel(
        review: StoreDetailReview,
        reasons: [ReportReason]
    ) -> ReportReviewBottomSheetViewModel {
        let config = ReportReviewBottomSheetViewModel.Config(
            storeId: state.storeId,
            reviewId: review.reviewId,
            reportReasons: reasons
        )
        let viewModel = ReportReviewBottomSheetViewModel(config: config)
        
        viewModel.output
            .onSuccessReport
            .subscribe(input.onSuccessReportReview)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
    
    private func presentVisit() {
        guard let overview = state.storeDetailData?.overview else { return }
        let config = VisitViewModel.Config(storeId: state.storeId, store: overview)
        let viewModel = VisitViewModel(config: config)
        
        viewModel.output.onSuccessVisit
            .subscribe(input.load)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentVisit(viewModel))
    }
    
    private func pushEditStore() {
        guard let storeDetailData = state.storeDetailData else { return }
        
        output.route.send(.pushEditStore(storeId: state.storeId, storeDetailData: storeDetailData))
    }
}

// MARK: Log
extension StoreDetailViewModel {
    private func sendClickSaveLog(isDelete: Bool) {
        let value = isDelete ? "off" : "on"
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickFavorite,
            extraParameters: [
                .storeId: state.storeId,
                .value: value
            ]))
    }
    
    private func sendClickEvent(_ eventName: EventName) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: eventName,
            extraParameters: [.storeId: state.storeId]
        ))
    }
}
