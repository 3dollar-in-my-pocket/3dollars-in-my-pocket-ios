import Combine

import Common
import Model

extension StoreDetailActionBarCellViewModel {
    struct Input {
        let didTapActionButton = PassthroughSubject<StoreDetailActionBarItemType, Never>()
        let updateSavedStatus = PassthroughSubject<Bool, Never>()
    }
    
    struct Output {
        let data: StoreActionBarSectionResponse
        let storeType: StoreType
        let favoriteStatus: CurrentValueSubject<Bool, Never>
        let favoriteCount: CurrentValueSubject<Int, Never>
        let didTapActionButton = PassthroughSubject<StoreDetailActionBarItemType, Never>()
    }
    
    struct Config {
        let data: StoreActionBarSectionResponse
        let storeType: StoreType
    }
}

final class StoreDetailActionBarCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(
            data: config.data,
            storeType: config.storeType,
            favoriteStatus: .init(config.data.favorite.isFavorite),
            favoriteCount: .init(config.data.favorite.favoriteCount)
        )
    }
    
    override func bind() {
        input.didTapActionButton
            .subscribe(output.didTapActionButton)
            .store(in: &cancellables)
        
        input.updateSavedStatus
            .sink { [weak self] isSaved in
                self?.updateSavedStatus(isSaved: isSaved)
            }
            .store(in: &cancellables)
    }
    
    private func updateSavedStatus(isSaved: Bool) {
        if isSaved {
            output.favoriteStatus.send(true)
            output.favoriteCount.send(output.favoriteCount.value + 1)
        } else {
            output.favoriteStatus.send(false)
            output.favoriteCount.send(output.favoriteCount.value - 1)
        }
    }
}
