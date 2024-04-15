import Combine

import Common

final class CommunityPopularStoreNeighborhoodsHeaderViewModel: BaseViewModel {
    struct Input {
        let title = PassthroughSubject<String?, Never>()
        let didTapBack = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let title = CurrentValueSubject<String?, Never>(nil)
        let didTapBack = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }
    
    let input = Input()
    let output = Output()
    
    override func bind() {
        input.title
            .subscribe(output.title)
            .store(in: &cancellables)
        
        input.didTapBack
            .sink(receiveValue: { [weak self] in
                self?.output.title.send(nil)
                self?.output.didTapBack.send(())
            })
            .store(in: &cancellables)
        
        input.didTapClose
            .subscribe(output.didTapClose)
            .store(in: &cancellables)
    }
}
