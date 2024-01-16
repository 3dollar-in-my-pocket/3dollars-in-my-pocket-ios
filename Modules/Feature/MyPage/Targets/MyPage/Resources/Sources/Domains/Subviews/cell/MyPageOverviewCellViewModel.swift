import Combine

import Common
import Model
import Networking
import Log

final class MyPageOverviewCellViewModel: BaseViewModel {
    struct Input {
        let didTapStoreCountButton = PassthroughSubject<Void, Never>()
        let didTapReviewButton = PassthroughSubject<Void, Never>()
        let didTapMedalImageButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let item: UserWithDetailApiResponse
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case store
        case review
        case medal
    }
    
    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    init(item: UserWithDetailApiResponse) {
        self.output = Output(item: item)

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapStoreCountButton
            .map { _ in .store }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapReviewButton
            .map { _ in .review }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapMedalImageButton
            .map { _ in .medal }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
}

extension MyPageOverviewCellViewModel: Hashable {
    static func == (lhs: MyPageOverviewCellViewModel, rhs: MyPageOverviewCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
