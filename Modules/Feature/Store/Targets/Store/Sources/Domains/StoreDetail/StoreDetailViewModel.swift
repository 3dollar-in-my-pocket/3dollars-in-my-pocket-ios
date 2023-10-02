import UIKit
import Combine

import Common
import Networking
import Model
import DependencyInjection
import AppInterface

final class StoreDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
        
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
        
        // 사진 섹션
        let didTapUploadPhoto = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let onSuccessUploadPhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
    }
    
    struct Output {
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
    }
    
    enum Route {
        case dismissReportModalAndPop
        case presentReport(ReportBottomSheetViewModel)
        case presentNavigation
        case presentWriteReview(ReviewBottomSheetViewModel)
        case presentMapDetail(MapDetailViewModel)
        case presentUploadPhoto(UploadPhotoViewModel)
        case pushPhotoList(PhotoListViewModel)
        case presentPhotoDetail(PhotoDetailViewModel)
    }
    
    let input = Input()
    let output = Output()
    var state: State
    private let storeService: StoreServiceProtocol
    private let userDefaults: UserDefaultsUtil
    
    init(
        storeId: Int,
        storeService: StoreServiceProtocol = StoreService(),
        userDefaults: UserDefaultsUtil = .shared
    ) {
        self.state = State(storeId: storeId)
        self.storeService = storeService
        self.userDefaults = userDefaults
        
        super.init()
    }
    
    override func bind() {
        bindOverviewSection()
        bindPhotoSection()
        
        input.viewDidLoad
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
            })
            .store(in: &cancellables)
    }
    
    private func bindOverviewSection() {
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                let isDeleted = owner.state.storeDetailData?.overview.isFavorited == true
                owner.saveStore(isDelete: isDeleted)
            }
            .store(in: &cancellables)
        
        input.didTapShare
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.shareKakao()
            }
            .store(in: &cancellables)
        
        input.didTapNavigation
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
            }
            .store(in: &cancellables)
        
        input.didTapMapDetail
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _) in
                owner.presentMapDetail()
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
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, photos: [StoreDetailPhoto]) in
                owner.state.storeDetailData?.photos += photos
                
                if let photos = owner.state.storeDetailData?.photos {
                    for index in photos.indices {
                        owner.state.storeDetailData?.photos[index].totalCount = photos.count
                    }
                }
                owner.refreshSections()
            }
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
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
    
    private func refreshSections() {
        guard let storeDetailData = state.storeDetailData else { return }
        
        output.sections.send([
            .overviewSection(createOverviewCellViewModel(storeDetailData.overview)),
            .visitSection(storeDetailData.visit),
            .infoSection(
                updatedAt: "2023.02.04 업데이트",
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
        let config = StoreDetailMenuCellViewModel.Config(menus: data.menus, isShowAll: false)
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
                    output.toast.send(Strings.StoreDetail.Toast.addFavorite)
                } else {
                    state.storeDetailData?.overview.isFavorited = true
                    state.storeDetailData?.overview.subscribersCount += 1
                    output.isFavorited.send(true)
                    output.toast.send(Strings.StoreDetail.Toast.removeFavorite)
                }
                output.subscribersCount.send(state.storeDetailData?.overview.subscribersCount ?? 0)
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func presentReportModal() {
        Task {
            let reportReasonResult = await storeService.fetchReportReasons(group: .store)
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
        
        appInterface.shareKakao(storeId: state.storeId, storeDetailOverview: overview)
    }
    
    private func presentWriteReviewBottomSheet() {
        let config = ReviewBottomSheetViewModel.Config(storeId: state.storeId)
        let viewModel = ReviewBottomSheetViewModel(config: config)
        
        viewModel.output.onSuccessWriteReview
            .subscribe(input.onSuccessWriteReview)
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
        let config = MapDetailViewModel.Config(storeDetailData: storeDetailData)
        let viewModel = MapDetailViewModel(config: config)
        
        output.route.send(.presentMapDetail(viewModel))
    }
    
    private func presentUploadPhoto() {
        let config = UploadPhotoViewModel.Config(storeId: state.storeId)
        let viewModel = UploadPhotoViewModel(config: config)
        
        viewModel.output.onSuccessUploadPhotos
            .subscribe(input.onSuccessUploadPhotos)
            .store(in: &cancellables)
        
        output.route.send(.presentUploadPhoto(viewModel))
    }
    
    private func pushPhotoList() {
        let config = PhotoListViewModel.Config(storeId: state.storeId)
        let viewModel = PhotoListViewModel(config: config)
        
        viewModel.output.onSuccessUploadPhotos
            .subscribe(input.onSuccessUploadPhotos)
            .store(in: &cancellables)
        
        output.route.send(.pushPhotoList(viewModel))
    }
    
    private func presentPhotoDetail(index: Int) {
        guard let photos = state.storeDetailData?.photos else { return }
        let config = PhotoDetailViewModel.Config(storeId: state.storeId, photos: photos, hasMore: true, currentIndex: index)
        let viewModel = PhotoDetailViewModel(config: config)
        
        output.route.send(.presentPhotoDetail(viewModel))
    }
}
