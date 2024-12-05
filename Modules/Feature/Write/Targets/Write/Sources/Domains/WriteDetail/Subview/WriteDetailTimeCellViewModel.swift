import Foundation
import Combine

import Common
import Model

final class WriteDetailTimeCellViewModel: BaseViewModel {
    struct Input {
        let inputStartDate = PassthroughSubject<String?, Never>()
        let inputEndDate = PassthroughSubject<String?, Never>()
    }
    
    struct Output {
        let inputStartDate: CurrentValueSubject<String?, Never>
        let inputEndDate: CurrentValueSubject<String?, Never>
    }
    
    private struct State {
        var startDate: String?
        var endDate: String?
    }
    
    struct Config {
        var startDate: String?
        var endDate: String?
    }
    
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        self.state = State(startDate: config.startDate, endDate: config.endDate)
        self.output = Output(
            inputStartDate: .init(config.startDate),
            inputEndDate: .init(config.endDate)
        )
        
        super.init()
    }
    
    override func bind() {
        input.inputStartDate
            .handleEvents(receiveOutput: { [weak self] (startDate: String?) in
                self?.state.startDate = startDate
            })
            .subscribe(output.inputStartDate)
            .store(in: &cancellables)
        
        input.inputEndDate
            .handleEvents(receiveOutput: { [weak self] (endDate: String?) in
                self?.state.endDate = endDate
            })
            .subscribe(output.inputEndDate)
            .store(in: &cancellables)
    }
}

extension WriteDetailTimeCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension WriteDetailTimeCellViewModel: Hashable  {
    static func == (lhs: WriteDetailTimeCellViewModel, rhs: WriteDetailTimeCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
