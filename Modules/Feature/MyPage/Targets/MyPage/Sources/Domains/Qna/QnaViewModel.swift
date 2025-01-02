import Foundation
import Combine

import Common
import Networking
import Log

public final class QnaViewModel: BaseViewModel {
    struct Input {
        let didTapCell = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .qna
        let datasource: [QnaCellType] = [.faq, .inquiry]
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushFAQ
        case goToKakao
    }
    
    let input = Input()
    let output = Output()
    private let userRepository: UserRepository
    
    public init(userRepository: UserRepository = UserRepositoryImpl()) {
        self.userRepository = userRepository
    }
    
    public override func bind() {
        input.didTapCell
            .withUnretained(self)
            .sink { (owner: QnaViewModel, index: Int) in
                guard let cellType = owner.output.datasource[safe: index] else { return }
                
                switch cellType {
                case .faq:
                    owner.output.route.send(.pushFAQ)
                case .inquiry:
                    owner.output.route.send(.goToKakao)
                }
            }
            .store(in: &cancellables)
    }
}
