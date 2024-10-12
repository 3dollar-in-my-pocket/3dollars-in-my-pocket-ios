import Foundation
import Combine

import Common

final class BirthdayYearBottomSheetViewModel: BaseViewModel {
    struct Input {
        let didSelectYear = PassthroughSubject<Int, Never>()
        let didTapConfirm = PassthroughSubject<Void, Never>()
        let viewWillAppear = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let dataSource: [Int]
        let selectYear = PassthroughSubject<Int, Never>()
        let didSelectYear = PassthroughSubject<Int, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var birthdayYear: Int?
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let birthdayYear: Int?
    }
    
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = currentYear - 100
        
        self.state = State(birthdayYear: config.birthdayYear ?? currentYear)
        self.output = Output(dataSource: Array(startYear...currentYear))
        
        super.init()
    }
    
    override func bind() {
        input.didSelectYear
            .withUnretained(self)
            .sink { (owner: BirthdayYearBottomSheetViewModel, index: Int) in
                owner.state.birthdayYear = owner.output.dataSource[safe: index]
            }
            .store(in: &cancellables)
        
        input.didTapConfirm
            .withUnretained(self)
            .sink { (owner: BirthdayYearBottomSheetViewModel, _) in
                owner.selectYear()
            }
            .store(in: &cancellables)
        
        input.viewWillAppear
            .withUnretained(self)
            .sink { (owner: BirthdayYearBottomSheetViewModel, _) in
                if let year = owner.state.birthdayYear,
                   let index = owner.output.dataSource.firstIndex(of: year) {
                    owner.output.selectYear.send(index)
                } else {
                    owner.output.selectYear.send(owner.output.dataSource.count - 1)
                }
            }
            .store(in: &cancellables)
    }
    
    private func selectYear() {
        guard let birthdayYear = state.birthdayYear else { return }
        
        output.didSelectYear.send(birthdayYear)
        output.route.send(.dismiss)
    }
}
