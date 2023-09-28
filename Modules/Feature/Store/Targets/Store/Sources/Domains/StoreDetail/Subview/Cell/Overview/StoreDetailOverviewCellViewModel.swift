import Combine

import Common
import Model
import Networking

final class StoreDetailOverviewCellViewModel: BaseViewModel {
    struct Input {
        // From cell
        let didTapFavorite = PassthroughSubject<Void, Never>()
        let didTapShare = PassthroughSubject<Void, Never>()
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapWriteReview = PassthroughSubject<Void, Never>()
        
        // From parent
        let isFavorited = PassthroughSubject<Bool, Never>()
        let subscribersCount = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let overview: StoreDetailOverview
        let didTapFavorite = PassthroughSubject<Void, Never>()
        let didTapShare = PassthroughSubject<Void, Never>()
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapWriteReview = PassthroughSubject<Void, Never>()
        
        let isFavorited = PassthroughSubject<Bool, Never>()
        let subscribersCount = PassthroughSubject<Int, Never>()
    }
    
    struct Config {
        let overview: StoreDetailOverview
    }
    
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(overview: config.overview)
        
        super.init()
    }
    
    override func bind() {
        input.didTapFavorite
            .subscribe(output.didTapFavorite)
            .store(in: &cancellables)
        
        input.didTapShare
            .subscribe(output.didTapShare)
            .store(in: &cancellables)
        
        input.didTapNavigation
            .subscribe(output.didTapNavigation)
            .store(in: &cancellables)
        
        input.didTapWriteReview
            .subscribe(output.didTapWriteReview)
            .store(in: &cancellables)
        
        input.isFavorited
            .subscribe(output.isFavorited)
            .store(in: &cancellables)
        
        input.subscribersCount
            .subscribe(output.subscribersCount)
            .store(in: &cancellables)
    }
}

extension StoreDetailOverviewCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension StoreDetailOverviewCellViewModel: Hashable {
    static func == (lhs: StoreDetailOverviewCellViewModel, rhs: StoreDetailOverviewCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
