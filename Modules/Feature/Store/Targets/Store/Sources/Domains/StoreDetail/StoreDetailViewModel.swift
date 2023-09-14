import Foundation
import Combine

import Common
import Networking
import Model

final class StoreDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapDelete = PassthroughSubject<Void, Never>()
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
        Task {
            let input = FetchStoreDetailInput(
                storeId: state.storeId,
                latitude: userDefaults.userCurrentLocation.coordinate.latitude,
                longitude: userDefaults.userCurrentLocation.coordinate.longitude
            )
            let storeDetailResult = await storeService.fetchStoreDetail(input: input)
            
            switch storeDetailResult {
            case .success(let response):
                let storeDetailData = StoreDetailData(response: response)
                output.sections.send([
                    .init(type: .overview, items: [.overview(storeDetailData.overview)]),
                    .init(type: .visit, items: [.visit(storeDetailData.visit)]),
                    .init(type: .info, header: .init(title: "가게 정보 & 메뉴", description: "2023.02.04 업데이트", value: nil, buttonTitle: "정보 수정"), items: [.info(storeDetailData.info)])
                ])
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
}
