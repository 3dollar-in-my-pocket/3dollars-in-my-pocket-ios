import Foundation
import Combine

import Networking
import Model
import Common

final class CreatePollModalViewModel: BaseViewModel {

    struct Input {
        let title = CurrentValueSubject<String, Never>("")
        let firstOption = CurrentValueSubject<String, Never>("")
        let secondOption = CurrentValueSubject<String, Never>("")
        let didTapCreateButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let pollRetentionDays: Int
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let created = PassthroughSubject<Void, Never>()
        let isEnabledCreateButton = CurrentValueSubject<Bool, Never>(false)
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {

    }

    enum Route {
        case back
    }

    let input = Input()
    let output: Output

    private var state = State()
    private let communityService: CommunityServiceProtocol

    init(
        pollRetentionDays: Int,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.output = Output(pollRetentionDays: pollRetentionDays)
        self.communityService = communityService

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapCreateButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                let title = owner.input.title.value
                let firstOption = owner.input.firstOption.value
                let secondOption = owner.input.secondOption.value
                guard title.isNotEmpty else { return nil }
                return PollCreateRequestInput(
                    title: title,
                    startDateTime: Date().toString(format: "yyyy-MM-dd'T'HH:mm:ss"),
                    endDateTime: Date().addDay(day: 3).toString(format: "yyyy-MM-dd'T'HH:mm:ss"),
                    options: [
                        .init(name: firstOption),
                        .init(name: secondOption)
                    ]
                )
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.createPoll(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.output.created.send()
                    owner.output.showToast.send("투표를 만들었어요!")
                    owner.output.route.send(.back)
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        input.title
            .combineLatest(input.firstOption, input.secondOption)
            .map {
                $0.0.isNotEmpty && $0.1.isNotEmpty && $0.2.isNotEmpty
            }
            .subscribe(output.isEnabledCreateButton)
            .store(in: &cancellables)
    }
}
