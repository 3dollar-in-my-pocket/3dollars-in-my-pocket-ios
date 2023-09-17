import Foundation
import Combine

import Networking
import Model
import Common

final class CommunityViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapPollCategoryButton = PassthroughSubject<Void, Never>()
        let didSelectPollItem = PassthroughSubject<String, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {

    }

    enum Route {
        case pollCategoryTab
        case pollDetail
    }

    let input = Input()
    let output = Output()

    private var state = State()

    override init() {
        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapPollCategoryButton
            .map { _ in .pollCategoryTab }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didSelectPollItem
            .map { _ in .pollDetail }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
}
