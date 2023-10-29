import Foundation
import Combine

import Networking
import Model
import Common

final class BossStoreDetailViewModel: BaseViewModel {

    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
    }

    struct State {

    }

    enum Route {
        case none
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
    }

    override func bind() {
        super.bind()

        input.firstLoad
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
                    print("@@@\(response)")
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

    }
}
