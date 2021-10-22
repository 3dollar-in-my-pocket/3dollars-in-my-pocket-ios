import RxSwift

class CategoryVC: BaseVC {
  
  private lazy var categoryView = CategoryView(frame: self.view.frame)
  private let viewModel = CategoryViewModel(categoryService: CategoryService())
  
  static func instance() -> UINavigationController {
    let categoryVC = CategoryVC(nibName: nil, bundle: nil).then {
      $0.tabBarItem = UITabBarItem(
        title: nil,
        image: UIImage(named: "ic_category"),
        tag: TabBarTag.home.rawValue
      )
    }
    
    return UINavigationController(rootViewController: categoryVC).then {
      $0.setNavigationBarHidden(true, animated: false)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = categoryView
    self.setupCollectionView()
    self.viewModel.input.viewDidLoad.onNext(())
    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.categories
      .bind(to: self.categoryView.categoryCollectionView.rx.items(
        cellIdentifier: CategoryCell.registerId,
        cellType: CategoryCell.self
      )) { _, category, cell in
        cell.bind(menuCategory: category)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToCategoryList
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToCategoryList(category:))
      .disposed(by: disposeBag)
  }
  
  private func setupCollectionView() {
    self.categoryView.categoryCollectionView.register(
      CategoryCell.self,
      forCellWithReuseIdentifier: CategoryCell.registerId
    )
    
    self.categoryView.categoryCollectionView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapCategory)
      .disposed(by: disposeBag)
  }
  
  private func goToCategoryList(category: StoreCategory) {
    let categoryVC = CategoryListVC.instance(category: category)
    
    self.navigationController?.pushViewController(categoryVC, animated: true)
  }
}
