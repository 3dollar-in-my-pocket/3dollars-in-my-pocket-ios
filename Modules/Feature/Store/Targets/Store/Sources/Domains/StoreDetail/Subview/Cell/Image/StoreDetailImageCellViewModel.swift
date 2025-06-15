import Combine

import Common
import Model

extension StoreDetailImageCellViewModel {
    struct Input {
        let didTapImage = PassthroughSubject<Int, Never>()
        let didTapHeaderButton = PassthroughSubject<Void, Never>()
        let didTapMore = PassthroughSubject<Void, Never>()
        
    }
    
    struct Output {
        let header: HeaderSectionResponse
        let images: CurrentValueSubject<[SDImage], Never>
        let more: StoreImagesSectionResponse.StoreImageMoreSectionResponse?
        let presentPhotoDetail = PassthroughSubject<Int, Never>()
        let deeplink = PassthroughSubject<SDLink, Never>()
    }
    
    struct Config {
        let data: StoreImagesSectionResponse
    }
}

final class StoreDetailImageCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(
            header: config.data.header,
            images: .init(config.data.cards),
            more: config.data.more
        )
        
        super.init()
    }
    
    override func bind() {
        input.didTapImage
            .sink { [weak self] index in
                self?.output.presentPhotoDetail.send(index)
            }
            .store(in: &cancellables)
        
        input.didTapHeaderButton
            .sink { [weak self] in
                guard let link = self?.output.header.rightButton?.link else { return }
                
                self?.output.deeplink.send(link)
            }
            .store(in: &cancellables)
    }
}
