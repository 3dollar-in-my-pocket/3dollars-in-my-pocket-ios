import UIKit
import GoogleMaps

class CategoryListVC: BaseVC {
    
    private lazy var categoryListView = CategoryListView(frame: self.view.frame)
    private var category: StoreCategory!
    
    static func instance(category: StoreCategory) -> CategoryListVC {
        return CategoryListVC(nibName: nil, bundle: nil).then {
            $0.category = category
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = categoryListView
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
        
        categoryListView.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
        marker.title = "닥고약기"
        marker.snippet = "무름표"
        marker.map = categoryListView.mapView
        
        categoryListView.pageCollectionView.delegate = self
        categoryListView.pageCollectionView.dataSource = self
        categoryListView.pageCollectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: CategoryCollectionCell.registerId)
        categoryListView.categoryBungeoppang.isSelected = true // Default setting
        tapCategory(selectedIndex: StoreCategory.categoryToIndex(self.category))
    }
    
    override func bindViewModel() {
        for index in categoryListView.categoryStackView.arrangedSubviews.indices {
            if let button = categoryListView.categoryStackView.arrangedSubviews[index] as? UIButton {
                button.rx.tap.bind { [weak self] in
                    self?.tapCategory(selectedIndex: index)
                    self?.categoryListView.pageCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                }.disposed(by: disposeBag)
            }
        }
        
        categoryListView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
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

extension CategoryListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionCell.registerId, for: indexPath) as? CategoryCollectionCell else {
            return BaseCollectionViewCell()
        }
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.categoryListView.pageCollectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        
        self.tapCategory(selectedIndex: itemAt)
    }
}

extension CategoryListVC: CategoryCollectionCellDelegate {
    func onTapBack() {
        self.navigationController?.pushViewController(DetailVC.instance(storeId: 1), animated: true)
    }
}
