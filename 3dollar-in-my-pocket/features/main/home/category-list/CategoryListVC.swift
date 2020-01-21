import UIKit
import GoogleMaps

class CategoryListVC: BaseVC {
    
    private lazy var categoryListView = CategoryListView(frame: self.view.frame)
    
    private lazy var pageVC = CategoryPageVC.instance(category: self.category)
    
    private var category: StoreCategory!
    
    
    static func instance(category: StoreCategory) -> CategoryListVC {
        return CategoryListVC(nibName: nil, bundle: nil).then {
            $0.category = category
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = categoryListView
        
        setupPageVC()
        tapCategory(selectedIndex: StoreCategory.categoryToIndex(category))
    }
    
    override func bindViewModel() {
        for index in categoryListView.categoryStackView.arrangedSubviews.indices {
            if let button = categoryListView.categoryStackView.arrangedSubviews[index] as? UIButton {
                button.rx.tap.bind { [weak self] in
                    self?.tapCategory(selectedIndex: index)
                    self?.pageVC.tapCategory(index: index)
                }.disposed(by: disposeBag)
            }
        }
        
        categoryListView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageVC.view.snp.makeConstraints { (make) in
            make.edges.equalTo(categoryListView.pageView)
        }
    }
    
    func setupMarker(store: [Store]) {
        // API 연동 하고나서 가게 위치들 찍어야함!
//        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
//
//        categoryListView.mapView.camera = camera
//
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
//        marker.title = "닥고약기"
//        marker.snippet = "무름표"
//        marker.map = categoryListView.mapView
    }
    
    private func setupPageVC() {
        addChild(pageVC)
        pageVC.pageDelegate = self
        categoryListView.pageView.addSubview(pageVC.view)
    }
    
    private func tapCategory(selectedIndex: Int) {
        categoryListView.setCategoryTitleImage(category: StoreCategory.index(selectedIndex))
        for index in self.categoryListView.categoryStackView.arrangedSubviews.indices {
            if let button = self.categoryListView.categoryStackView.arrangedSubviews[index] as? UIButton {
                button.isSelected = (index == selectedIndex)
            }
        }
    }
}

extension CategoryListVC: CategoryPageDelegate {
    func onScrollPage(index: Int) {
        self.tapCategory(selectedIndex: index)
    }
}
