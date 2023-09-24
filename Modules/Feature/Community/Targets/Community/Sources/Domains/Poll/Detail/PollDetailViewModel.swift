import Foundation
import Combine

import Networking
import Model
import Common

final class PollDetailViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapReportButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {

    }

    enum Route {
        case report(ReportPollViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let pollId: String

    init(pollId: String) {
        self.pollId = pollId

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapReportButton
            .withUnretained(self)
            .map { owner, _ in
                .report(ReportPollViewModel(pollId: owner.pollId))
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
}
