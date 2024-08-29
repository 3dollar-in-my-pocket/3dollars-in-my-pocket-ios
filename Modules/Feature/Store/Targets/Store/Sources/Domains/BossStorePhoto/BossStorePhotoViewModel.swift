import Combine

import Common
import Model
import Log


extension BossStorePhotoViewModel {
    struct Input {
        let didTapLeft = PassthroughSubject<Void, Never>()
        let didTapRight = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .bossStorePhoto
        let photos: [ImageResponse]
        let scrollToIndex = PassthroughSubject<Int, Never>()
        let currentIndex = PassthroughSubject<Int, Never>()
    }
    
    struct State {
        var currentIndex = 0
    }
    
    struct Config {
        let photos: [ImageResponse]
        let selectedIndex: Int
    }
}

final class BossStorePhotoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state = State()
    
    init(config: Config) {
        self.output = Output(photos: config.photos)
        
        super.init()
    }
    
    override func bind() {
        input.didTapLeft
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewModel, _) in
                let leftIndex = owner.state.currentIndex - 1
                
                if leftIndex < 0 {
                    owner.state.currentIndex = 0
                } else {
                    owner.state.currentIndex = leftIndex
                }
                owner.output.scrollToIndex.send(owner.state.currentIndex)
            }
            .store(in: &cancellables)
        
        input.didTapRight
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewModel, _) in
                let rightIndex = owner.state.currentIndex + 1
                
                if rightIndex >= (owner.output.photos.count - 1) {
                    owner.state.currentIndex = owner.output.photos.count - 1
                } else {
                    owner.state.currentIndex = rightIndex
                }
                owner.output.scrollToIndex.send(owner.state.currentIndex)
            }
            .store(in: &cancellables)
    }
}
