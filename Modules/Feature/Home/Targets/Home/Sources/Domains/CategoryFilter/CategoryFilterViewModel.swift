import Foundation
import Combine

import Common
import Networking

final class CategoryFilterViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onTapBanner = PassthroughSubject<Void, Never>()
        let onTapCategory = PassthroughSubject<String, Never>()
        let onCollectionViewLoaded = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let advertisement = PassthroughSubject<Advertisement?, Never>()
        let categories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let selectCategory = PassthroughSubject<PlatformStoreCategory?, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var currentCategory: PlatformStoreCategory?
        var advertisement: Advertisement?
        var categories: [PlatformStoreCategory]
    }
    
    enum Route {
        case showErrorAlert(Error)
        case dismissWithCategory(PlatformStoreCategory?)
        case goToWeb(url: String)
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private let categoryService: CategoryServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    
    init(
        category: PlatformStoreCategory?,
        categoryService: CategoryServiceProtocol = CategoryService(),
        advertisementService: AdvertisementServiceProtocol = AdvertisementService()
    ) {
        self.state = State(currentCategory: category, advertisement: nil, categories: [])
        self.categoryService = categoryService
        self.advertisementService = advertisementService
        
        super.init()
    }
    
    override func bind() {
        let fetchCategories = input.viewDidLoad
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.categoryService.fetchCategoires()
            }
            .share()
        
        fetchCategories
            .compactMapValue()
            .map { response in
                response.map { PlatformStoreCategory(response: $0) }
            }
            .withUnretained(self)
            .sink { owner, categories in
                owner.state.categories = categories
                owner.output.categories.send(categories)
            }
            .store(in: &cancellables)
        
        fetchCategories
            .compactMapError()
            .map { Route.showErrorAlert($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        let fetchAdvertisement = input.viewDidLoad
            .withUnretained(self)
            .asyncMap { owner, _ in
                let input = FetchAdvertisementInput(position: .menuCategoryBanner, size: nil)
                
                return await owner.advertisementService.fetchAdvertisements(input: input)
            }
            .share()
        
        fetchAdvertisement
            .compactMapValue()
            .withUnretained(self)
            .sink { owner, advertisements in
                if let advertisementResponse = advertisements.first {
                    let advertisement = Advertisement(response: advertisementResponse)
                    
                    owner.state.advertisement = advertisement
                    owner.output.advertisement.send(advertisement)
                } else {
                    owner.output.advertisement.send(nil)
                }
            }
            .store(in: &cancellables)
        
        fetchAdvertisement
            .compactMapError()
            .map { _ in nil }
            .subscribe(output.advertisement)
            .store(in: &cancellables)
        
        input.onTapBanner
            .withUnretained(self)
            .compactMap { owner, _ in
                guard let advertisement = owner.state.advertisement,
                      let linkUrl = advertisement.linkUrl else { return  nil }
                
                return Route.goToWeb(url: linkUrl)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.onTapCategory
            .withUnretained(self)
            .sink { owner, categoryId in
                guard let selectedCategory = owner.state.categories.first(where: { $0.categoryId == categoryId }) else { return }
                
                if selectedCategory == owner.state.currentCategory {
                    owner.output.route.send(.dismissWithCategory(nil))
                } else {
                    owner.output.route.send(.dismissWithCategory(selectedCategory))
                }
            }
            .store(in: &cancellables)
        
        input.onCollectionViewLoaded
            .withUnretained(self)
            .map { owner, _ -> PlatformStoreCategory? in
                return owner.state.currentCategory
            }
            .subscribe(output.selectCategory)
            .store(in: &cancellables)
    }
}
