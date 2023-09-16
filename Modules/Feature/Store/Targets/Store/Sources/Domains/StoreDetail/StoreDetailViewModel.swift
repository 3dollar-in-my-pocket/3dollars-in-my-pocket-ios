import Foundation
import Combine

import Common
import Networking
import Model

final class StoreDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapDelete = PassthroughSubject<Void, Never>()
        let didTapShowMoreMenu = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let sections = PassthroughSubject<[StoreDetailSection], Never>()
    }
    
    struct State {
        let storeId: Int
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
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: StoreDetailViewModel, _: Void) in
                owner.fetchStoreDetail()
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
                let storeDetailData = StoreDetailData(response: response)
                let photoCount = response.images.cursor.totalCount
                let reviewCount = response.reviews.cursor.totalCount
                
                output.sections.send([
                    .overviewSection(storeDetailData.overview),
                    .visitSection(storeDetailData.visit),
                    .infoSection(
                        updatedAt: "2023.02.04 업데이트",
                        info: storeDetailData.info,
                        menuCellViewModel: createMenuCellViewModel(storeDetailData)
                    ),
                    .photoSection(totalCount: photoCount, photos: storeDetailData.photos),
                    .reviewSection(
                        totalCount: reviewCount,
                        rating: storeDetailData.rating,
                        reviews: storeDetailData.reviews
                    )
                ])
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
    
    private func createMenuCellViewModel(_ data: StoreDetailData) -> StoreDetailMenuCellViewModel {
        let config = StoreDetailMenuCellViewModel.Config(menus: data.menus, isShowAll: false)
        let viewModel = StoreDetailMenuCellViewModel(config: config)
        
        viewModel.output.didTapMore
            .subscribe(input.didTapShowMoreMenu)
            .store(in: &cancellables)
        
        return viewModel
    }
}
