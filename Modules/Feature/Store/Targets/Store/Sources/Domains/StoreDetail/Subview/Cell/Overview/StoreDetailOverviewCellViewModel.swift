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
        let didTapAddress = PassthroughSubject<Void, Never>()
        let didTapMapDetail = PassthroughSubject<Void, Never>()
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let didTapTooltip = PassthroughSubject<Void, Never>()

        // From parent
        let isFavorited = PassthroughSubject<Bool, Never>()
        let subscribersCount = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var overview: StoreDetailOverview
        var menuList: [StoreDetailOverviewMenuItemType]
        let didTapFavorite = PassthroughSubject<Void, Never>()
        let didTapShare = PassthroughSubject<Void, Never>()
        let didTapNavigation = PassthroughSubject<Void, Never>()
        let didTapWriteReview = PassthroughSubject<Void, Never>()
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let didTapAddress = PassthroughSubject<Void, Never>()
        let didTapMapDetail = PassthroughSubject<Void, Never>()
        let showTooltip: CurrentValueSubject<Bool, Never>
        
        let isFavorited = PassthroughSubject<Bool, Never>()
        let subscribersCount = PassthroughSubject<Int, Never>()
    }
    
    struct Config {
        let overview: StoreDetailOverview
    }
    
    struct Dependency {
        let preference: Preference
        
        init(preference: Preference = .shared) {
            self.preference = preference
        }
    }
    
    let input = Input()
    var output: Output
    private var dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(
            overview: config.overview,
            menuList: config.overview.menuList,
            showTooltip: .init(dependency.preference.shownBookmarkTooltip.isNot && config.overview.isBossStore)
        )
        self.dependency = dependency

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

        input.didTapSnsButton
            .subscribe(output.didTapSnsButton)
            .store(in: &cancellables)

        input.isFavorited
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: StoreDetailOverviewCellViewModel, isFavorited: Bool) in
                owner.output.overview.isFavorited = isFavorited
                if isFavorited {
                    owner.output.overview.subscribersCount += 1
                } else {
                    owner.output.overview.subscribersCount -= 1
                }
                
                owner.output.menuList = owner.output.overview.menuList
            })
            .map { $1 }
            .subscribe(output.isFavorited)
            .store(in: &cancellables)
        
        input.subscribersCount
            .subscribe(output.subscribersCount)
            .store(in: &cancellables)
        
        input.didTapAddress
            .subscribe(output.didTapAddress)
            .store(in: &cancellables)
        
        input.didTapMapDetail
            .subscribe(output.didTapMapDetail)
            .store(in: &cancellables)
        
        input.didTapTooltip
            .withUnretained(self)
            .sink { (owner: StoreDetailOverviewCellViewModel, _) in
                owner.dependency.preference.shownBookmarkTooltip = true
                owner.output.showTooltip.send(false)
            }
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

private extension StoreDetailOverview {
    var menuList: [StoreDetailOverviewMenuItemType] {
        var itemList: [StoreDetailOverviewMenuItemType] = [
            .save,
            .share,
            .navigation,
        ]

        if isBossStore {
            itemList.append(.sns)
        } else {
            itemList.append(.review)
        }

        return itemList
    }
}
