import UIKit
import GoogleMaps

class CategoryListVC: BaseVC {
    
    private lazy var categoryListView = CategoryListView(frame: self.view.frame)
    
    private var pageVC: CategoryPageVC!
    
    private var category: StoreCategory!
    
    private var myLocationFlag = false
    
    var locationManager = CLLocationManager()
    
    
    static func instance(category: StoreCategory) -> CategoryListVC {
        return CategoryListVC(nibName: nil, bundle: nil).then {
            $0.category = category
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = categoryListView
        
        tapCategory(selectedIndex: StoreCategory.categoryToIndex(category))
        setupLocationManager()
        setupGoogleMap()
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
        
        categoryListView.myLocationBtn.rx.tap.bind { [weak self] in
            self?.myLocationFlag = true
            self?.locationManager.startUpdatingLocation()
        }.disposed(by: disposeBag)
        
        categoryListView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGoogleMap() {
        categoryListView.mapView.isMyLocationEnabled = true
    }
    
    private func setupPageVC(latitude: Double, longitude: Double) {
        pageVC = CategoryPageVC.instance(category: self.category, latitude: latitude, longitude: longitude )
        addChild(pageVC)
        pageVC.pageDelegate = self
        categoryListView.pageView.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { (make) in
            make.edges.equalTo(categoryListView.pageView)
        }
    }
    
    private func tapCategory(selectedIndex: Int) {
        categoryListView.setCategoryTitleImage(category: StoreCategory.index(selectedIndex))
        for index in self.categoryListView.categoryStackView.arrangedSubviews.indices {
            if let button = self.categoryListView.categoryStackView.arrangedSubviews[index] as? UIButton {
                button.isSelected = (index == selectedIndex)
            }
        }
    }
    
    private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension CategoryListVC: CategoryPageDelegate {
    func setMarker(storeCards: [StoreCard]) {
        self.categoryListView.mapView.clear()
        
        for store in storeCards {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
            marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_off")!, scaledToSize: CGSize.init(width: 16, height: 16))
            marker.map = categoryListView.mapView
        }
    }
    
    func onScrollPage(index: Int) {
        self.tapCategory(selectedIndex: index)
    }
}

extension CategoryListVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 15)
        
        self.categoryListView.mapView.animate(to: camera)
        
        if !self.myLocationFlag {
            self.setupPageVC(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            self.myLocationFlag = false
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
    }
}

