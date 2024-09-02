import Combine

import Common
import Model
import Log


extension BossStorePhotoViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapLeft = PassthroughSubject<Void, Never>()
        let didTapRight = PassthroughSubject<Void, Never>()
        let didScroll = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .bossStorePhoto
        let photos: [ImageResponse]
        let scrollToIndex = PassthroughSubject<Int, Never>()
        let currentIndex: CurrentValueSubject<Int, Never>
    }
    
    struct State {
        var currentIndex: Int
    }
    
    struct Config {
        let photos: [ImageResponse]
        let selectedIndex: Int
    }
}

final class BossStorePhotoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        self.output = Output(photos: config.photos, currentIndex: .init(config.selectedIndex))
        self.state = State(currentIndex: config.selectedIndex)
        super.init()
    }
    
    override func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewModel, _) in
                owner.output.scrollToIndex.send(owner.state.currentIndex)
            }
            .store(in: &cancellables)
        
        input.didTapLeft
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewModel, _) in
                owner.scrollToNext()
            }
            .store(in: &cancellables)
        
        input.didTapRight
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewModel, _) in
                owner.scrollToBefore()
            }
            .store(in: &cancellables)
        
        input.didScroll
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewModel, index: Int) in
                owner.handleScroll(index: index)
            }
            .store(in: &cancellables)
    }
    
    private func scrollToNext() {
        let leftIndex = state.currentIndex - 1
        
        if leftIndex < 0 {
            state.currentIndex = 0
        } else {
            state.currentIndex = leftIndex
        }
        output.scrollToIndex.send(state.currentIndex)
        output.currentIndex.send(state.currentIndex)
    }
    
    private func scrollToBefore() {
        let rightIndex = state.currentIndex + 1
        
        if rightIndex >= (output.photos.count - 1) {
            state.currentIndex = output.photos.count - 1
        } else {
            state.currentIndex = rightIndex
        }
        output.scrollToIndex.send(state.currentIndex)
        output.currentIndex.send(state.currentIndex)
    }
    
    private func handleScroll(index: Int) {
        state.currentIndex = index
        output.currentIndex.send(state.currentIndex)
    }
}
