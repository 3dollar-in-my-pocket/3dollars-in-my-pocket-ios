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

    private let storeId: String

    init(
        storeId: String,
        storeService: StoreServiceProtocol = StoreService()
    ) {
        self.storeId = storeId
        self.storeService = storeService

        super.init()
    }

    override func bind() {
        super.bind()
    }
}
