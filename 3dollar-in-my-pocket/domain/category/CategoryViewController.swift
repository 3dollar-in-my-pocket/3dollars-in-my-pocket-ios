import UIKit

import ReactorKit

final class CategoryViewController: BaseVC, View, CategoryCoordinator {
    private let categoryView = CategoryView()
    private let categoryReactor = CategoryReactor(
        categoryService: CategoryService(),
        popupService: PopupService()
    )
    private weak var coordinator: CategoryCoordinator?
    
    static func instance() -> UINavigationController {
        let viewController = CategoryViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_category"),
                tag: TabBarTag.home.rawValue
            )
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.setNavigationBarHidden(true, animated: false)
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func loadView() {
        self.view = self.categoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.categoryReactor
        self.coordinator = self
        self.categoryReactor.action.onNext(.viewDidLoad) 
    }
    
    override func bindEvent() {
        self.categoryReactor.pushCategoryListPublisher
            .asDriver(onErrorJustReturn: .BUNGEOPPANG)
            .drive(onNext: { [weak self] category in
                self?.coordinator?.pushCategoryList(category: category)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.categoryReactor.goToWebPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] url in
                
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: CategoryReactor) {
        // Bind Action
        self.categoryView.categoryCollectionView.rx.itemSelected
            .map { Reactor.Action.tapCategory(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.categories }
            .asDriver(onErrorJustReturn: [])
            .drive(self.categoryView.categoryCollectionView.rx.items(
                cellIdentifier: CategoryCell.registerId,
                cellType: CategoryCell.self
            )) { _, category, cell in
                cell.bind(menuCategory: category)
            }
            .disposed(by: disposeBag)
    }
}
