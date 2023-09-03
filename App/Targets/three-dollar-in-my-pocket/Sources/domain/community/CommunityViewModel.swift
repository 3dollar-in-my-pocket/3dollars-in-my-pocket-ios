import Foundation
import Combine

import Networking
import Model
import Common

final class CommunityViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {

    }

    enum Route {
        case none
    }

    let input = Input()
    let output = Output()

    private var state = State()

    override init() {
        super.init()
    }

    override func bind() {
        super.bind()
    }
}
