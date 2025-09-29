import Combine
import Foundation

import Common
import Model

extension MenuInputViewModel {
    struct Input {
        let inputName = PassthroughSubject<String, Never>()
        let inputQuantity = PassthroughSubject<String, Never>()
        let inputPrice = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let name: CurrentValueSubject<String?, Never>
        let quantity: CurrentValueSubject<Int?, Never>
        let price: CurrentValueSubject<Int?, Never>
    }
    
    struct Config {
        let menu: UserStoreMenuRequestV3
    }
}

final class MenuInputViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(
            name: .init(config.menu.name),
            quantity: .init(config.menu.count),
            price: .init(config.menu.price)
        )
        
        super.init()
    }
    
    override func bind() {
        input.inputName
            .sink(receiveValue: { [weak self] name in
                self?.output.name.send(name)
            })
            .store(in: &cancellables)
        
        input.inputQuantity
            .sink(receiveValue: { [weak self] quantity in
                self?.output.quantity.send(quantity.decimal)
            })
            .store(in: &cancellables)
        
        input.inputPrice
            .sink(receiveValue: { [weak self] price in
                self?.output.price.send(price.decimal)
            })
            .store(in: &cancellables)
    }
}
