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
        case presentMail(nickname: String)
    }
    
    let input = Input()
    let output = Output()
    private let userService: UserServiceProtocol
    
    public init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
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
                    owner.presentMail()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUserNickname() async -> String {
        let result = await userService.fetchUser()
        
        switch result {
        case .success(let response):
            return response.name
        case .failure:
            return ""
        }
    }
    
    private func presentMail() {
        Task {
            let nickname = await fetchUserNickname()
            
            output.route.send(.presentMail(nickname: nickname))
        }
        .store(in: taskBag)
    }
}
