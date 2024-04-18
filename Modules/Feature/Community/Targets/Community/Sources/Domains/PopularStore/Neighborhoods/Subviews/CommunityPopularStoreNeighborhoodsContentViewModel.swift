import Combine

import Common
import Model

final class CommunityPopularStoreNeighborhoodsContentViewModel: BaseViewModel {
    struct Input {
        let didSelectItem = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let datasource: CurrentValueSubject<[CommunityPopularStoreNeighborhoodsSection], Never>
        let didSelectItem = PassthroughSubject<NeighborhoodProtocol, Never>()
    }
    
    struct Config {
        let neighborhoods: [NeighborhoodProtocol]
    }
    
    let input = Input()
    let output: Output
    
    init(config: Config) {
        var items: [CommunityPopularStoreNeighborhoodsSectionItem]
        if let neighborhood = config.neighborhoods.first,
           let province = neighborhood as? CommunityNeighborhoodProvince {
            items = config.neighborhoods
                .compactMap { $0 as? CommunityNeighborhoodProvince }
                .map { .province($0) }
        } else {
            items = config.neighborhoods
                .compactMap { $0 as? CommunityNeighborhoods }
                .map { .district($0) }
        }
        let sections = [CommunityPopularStoreNeighborhoodsSection(items: items)]
        self.output = Output(datasource: .init(sections))
        super.init()
    }
    
    override func bind() {
        input.didSelectItem
            .withUnretained(self)
            .compactMap { (owner: CommunityPopularStoreNeighborhoodsContentViewModel, index: Int) -> NeighborhoodProtocol? in
                guard let section = owner.output.datasource.value.first,
                      let item = section.items[safe: index] else { return nil }
                
                switch item {
                case .district(let communityNeighborhoods):
                    return communityNeighborhoods
                case .province(let communityNeighborhoodProvince):
                    return communityNeighborhoodProvince
                }
            }
            .subscribe(output.didSelectItem)
            .store(in: &cancellables)
    }
}
