import Foundation
import Combine

import Networking
import Model
import Common

final class CommunityPopularStoreNeighborhoodsViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<NeighborhoodProtocol, Never>()
        
        // headerViewModel
        let didTapBack = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let contentViewModel = PassthroughSubject<CommunityPopularStoreNeighborhoodsContentViewModel, Never>()
        let updatePopularStores = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    enum Route {
        case pushDistrict(CommunityPopularStoreNeighborhoodsContentViewModel)
        case back
        case dismiss
    }

    let input = Input()
    let output = Output()
    let headerViewModel = CommunityPopularStoreNeighborhoodsHeaderViewModel()

    private let communityService: CommunityServiceProtocol
    private let preference = Preference.shared

    init(communityService: CommunityServiceProtocol = CommunityService()) {
        self.communityService = communityService

        super.init()
    }

    override func bind() {
        super.bind()
        bindHeaderViewModel()

        input.firstLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.communityService.fetchPopularStoreNeighborhoods()
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                let selectedItem = owner.preference.communityPopularStoreNeighborhoods.district
                switch result {
                case .success(let response):
                    let provinceList = response.neighborhoods.map {
                        let districts = $0.districts.map {
                            CommunityNeighborhoods(
                                district: $0.district,
                                description: $0.description,
                                isSelected: $0.district == selectedItem
                            )
                        }
                        
                        return CommunityNeighborhoodProvince(
                            province: $0.province,
                            description: $0.description,
                            districts: districts,
                            isSelected: districts.contains(where: { $0.isSelected })
                        )
                    }
                    owner.bindProvinceViewModel(provinceList: provinceList)
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.didTapBack
            .map { _ in Route.back }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapClose
            .map { _ in Route.dismiss }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func bindHeaderViewModel() {
        headerViewModel.output.didTapBack
            .subscribe(input.didTapBack)
            .store(in: &headerViewModel.cancellables)
        
        headerViewModel.output.didTapClose
            .subscribe(input.didTapClose)
            .store(in: &headerViewModel.cancellables)
    }
    
    private func bindProvinceViewModel(provinceList: [CommunityNeighborhoodProvince]) {
        let config = CommunityPopularStoreNeighborhoodsContentViewModel.Config(neighborhoods: provinceList)
        let viewModel = CommunityPopularStoreNeighborhoodsContentViewModel(config: config)
        
        viewModel.output.didSelectItem
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreNeighborhoodsViewModel, neighborhoodProtocol: NeighborhoodProtocol) in
                owner.bindDistrictViewModel(neighborhoodProtocol)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.output.didSelectItem
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreNeighborhoodsViewModel, neighborhoodProtocol: NeighborhoodProtocol) in
                owner.headerViewModel.input.title.send(neighborhoodProtocol.description)
            }
            .store(in: &viewModel.cancellables)
        
        output.contentViewModel.send(viewModel)
    }
    
    private func bindDistrictViewModel(_ neighborhood :NeighborhoodProtocol) {
        guard let province = neighborhood as? CommunityNeighborhoodProvince else{ return }
        
        let config = CommunityPopularStoreNeighborhoodsContentViewModel.Config(neighborhoods: province.districts)
        let viewModel = CommunityPopularStoreNeighborhoodsContentViewModel(config: config)
        
        viewModel.output.didSelectItem
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreNeighborhoodsViewModel, neighborhoodProtocol: NeighborhoodProtocol) in
                if let neighborhoods = neighborhoodProtocol as? CommunityNeighborhoods {
                    owner.preference.communityPopularStoreNeighborhoods = neighborhoods
                    owner.output.updatePopularStores.send(())
                    owner.output.route.send(.dismiss)
                }
            }
            .store(in: &viewModel.cancellables)
        
        output.route.send(.pushDistrict(viewModel))
    }
}
