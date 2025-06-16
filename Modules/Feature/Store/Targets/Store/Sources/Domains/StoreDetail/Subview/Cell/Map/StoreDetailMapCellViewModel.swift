import Combine

import Common
import Model

extension StoreDetailMapCellViewModel {
    struct Input {
        let didTapAddress = PassthroughSubject<Void, Never>()
        let didTapMapDetail = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let copyToClipboard = PassthroughSubject<String, Never>()
        let presentMapDetail = PassthroughSubject<LocationResponse, Never>()
        let data: StoreMapSectionResponse
    }
    
    struct Config {
        let data: StoreMapSectionResponse
    }
}

final class StoreDetailMapCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(data: config.data)
        
        super.init()
    }
    
    override func bind() {
        input.didTapAddress
            .sink { [weak self] _ in
                guard let address = self?.output.data.addressName?.text else { return }
                
                self?.output.copyToClipboard.send(address)
            }
            .store(in: &cancellables)
        
        input.didTapMapDetail
            .sink { [weak self] in
                guard let location = self?.output.data.location else { return }
                
                self?.output.presentMapDetail.send(location)
            }
            .store(in: &cancellables)
    }
}

extension StoreDetailMapCellViewModel: Hashable {
    static func == (lhs: StoreDetailMapCellViewModel, rhs: StoreDetailMapCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
    }
}
