import UIKit
import GoogleMaps

protocol HomeDelegate {
    func onTapCategory(category: StoreCategory)
    
    func didDragMap()
    
    func endDragMap()
}

class HomeVC: BaseVC {
    
    var viewModel = HomeViewModel()
    var delegate: HomeDelegate?
    var locationManager = CLLocationManager()
    var isFirst = true
    var previousIndex = 0
    var mapAnimatedFlag = false
    
    private lazy var homeView = HomeView(frame: self.view.frame)
    
    
    static func instance() -> HomeVC {
        return HomeVC(nibName: nil, bundle: nil)
    }
    
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = homeView
        
        setupShopCollectionView()
        setupGoogleMap()
        setupLocationManager()
    }
    
    override func bindViewModel() {
        viewModel.nearestStore
            .bind(to: homeView.shopCollectionView.rx.items(cellIdentifier: ShopCell.registerId, cellType: ShopCell.self)) { [weak self] row, storeCard, cell in
                if let vc = self {
                    if row == 0 && vc.isFirst == true {
                        cell.setSelected(isSelected: true)
                        vc.isFirst = false
                    } else {
                        cell.setSelected(isSelected: false)
                    }
                    cell.bind(storeCard: storeCard)
                }
        }.disposed(by: disposeBag)
        
        viewModel.location.subscribe(onNext: { [weak self] (latitude, longitude) in
            self?.previousIndex = 0
            self?.getNearestStore(latitude: latitude, longitude: longitude)
        }).disposed(by: disposeBag)
        
        homeView.mapButton.rx.tap.bind { [weak self] in
            self?.mapAnimatedFlag = true
            self?.locationManager.startUpdatingLocation()
        }.disposed(by: disposeBag)
        
        homeView.bungeoppangTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory(category: .BUNGEOPPANG)
        }.disposed(by: disposeBag)
        
        homeView.takoyakiTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory(category: .TAKOYAKI)
        }.disposed(by: disposeBag)
        
        homeView.gyeranppangTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory(category: .GYERANPPANG)
        }.disposed(by: disposeBag)
        
        homeView.hotteokTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory(category: .HOTTEOK)
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        previousIndex = 0
//        mapAnimatedFlag = false
//        locationManager.startUpdatingLocation() // 화면 돌아올때마다 갱신해주면 좋을 것 같음!
    }
    
    private func setupShopCollectionView() {
        homeView.shopCollectionView.delegate = self
        homeView.shopCollectionView.register(ShopCell.self, forCellWithReuseIdentifier: ShopCell.registerId)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGoogleMap() {
        homeView.mapView.delegate = self
        homeView.mapView.isMyLocationEnabled = true
    }
    
    private func goToDetail(storeId: Int) {
        self.navigationController?.pushViewController(DetailVC.instance(storeId: storeId), animated: true)
    }
    
    private func getNearestStore(latitude: Double, longitude: Double) {
        LoadingViewUtil.addLoadingView()
        StoreService.getStoreOrderByNearest(latitude: latitude, longitude: longitude) { [weak self] (response) in
            switch response.result {
            case .success(let storeCards):
                self?.isFirst = true
                self?.viewModel.nearestStore.onNext(storeCards)
                self?.homeView.shopCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
                self?.selectMarker(selectedIndex: 0, storeCards: storeCards)
            case .failure(let error):
                AlertUtils.show(title: "error", message: error.localizedDescription)
            }
            LoadingViewUtil.removeLoadingView()
        }
    }
    
    private func setMarker(storeCards: [StoreCard]) {
        homeView.mapView.clear()
        for storeCard in storeCards {
            let marker = GMSMarker()
            
            marker.position = CLLocationCoordinate2D(latitude: storeCard.latitude, longitude: storeCard.longitude)
            marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_off")!, scaledToSize: CGSize.init(width: 16 * UIScreen.main.bounds.width / 375, height: 16 * UIScreen.main.bounds.width / 375))
            marker.map = homeView.mapView
            viewModel.markers.append(marker)
        }
    }
    
    private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func selectMarker(selectedIndex: Int, storeCards: [StoreCard]) {
        self.homeView.mapView.clear()
        
        for index in storeCards.indices {
            let storeCard = storeCards[index]
            let marker = GMSMarker()
            
            marker.position = CLLocationCoordinate2D(latitude: storeCard.latitude, longitude: storeCard.longitude)
            if index == selectedIndex {
                self.homeView.mapView.animate(toLocation: marker.position)
                marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_on")!, scaledToSize: CGSize.init(width: 16, height: 16))
            } else {
                marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_off")!, scaledToSize: CGSize.init(width: 16, height: 16))
            }
            marker.map = homeView.mapView
        }
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 172, height: 172)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if previousIndex == indexPath.row { // 셀이 선택된 상태에서 한번 더 누르는 경우 상세화면으로 이동
            goToDetail(storeId: try! self.viewModel.nearestStore.value()[indexPath.row].id)
        } else {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            if let cell = self.homeView.shopCollectionView.cellForItem(at: IndexPath(row: previousIndex, section: 0)) as? ShopCell {
                // 기존에 눌려있던 셀 deselect
                cell.setSelected(isSelected: false)
            }
            
            if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
                // 새로 누른 셀 select
                cell.setSelected(isSelected: true)
                self.selectMarker(selectedIndex: indexPath.row, storeCards: try! self.viewModel.nearestStore.value())
            }
            previousIndex  = indexPath.row
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = CGFloat(172 * RadioUtils.width)
        let proportionalOffset = scrollView.contentOffset.x / pageWidth
        
        previousIndex = Int(proportionalOffset.rounded())
        if previousIndex < 0 {
            previousIndex = 0
        }
        
        let indexPath = IndexPath(row: previousIndex, section: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.homeView.shopCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth = CGFloat(172 * RadioUtils.width)
        let proportionalOffset = scrollView.contentOffset.x / pageWidth
        
        previousIndex = Int(proportionalOffset.rounded())
        if previousIndex < 0 {
            previousIndex = 0
        }
        
        let indexPath = IndexPath(row: previousIndex, section: 0)
        
        if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
            cell.setSelected(isSelected: true)
            self.selectMarker(selectedIndex: indexPath.row, storeCards: try! self.viewModel.nearestStore.value())
        }
    }


    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let pageWidth = CGFloat(172 * RadioUtils.width)
            let proportionalOffset = scrollView.contentOffset.x / pageWidth
            previousIndex = Int(round(proportionalOffset))
            let indexPath = IndexPath(row: previousIndex, section: 0)

            self.homeView.shopCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
                cell.setSelected(isSelected: true)
                self.selectMarker(selectedIndex: indexPath.row, storeCards: try! self.viewModel.nearestStore.value())
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let indexPath = IndexPath(row: previousIndex, section: 0)

        if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
            cell.setSelected(isSelected: false)
        }
    }
}

extension HomeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            self.delegate?.didDragMap()
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.delegate?.endDragMap()
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 15)
        
        if self.mapAnimatedFlag {
            self.homeView.mapView.animate(to: camera)
        } else {
            self.homeView.mapView.camera = camera
        }
        if isFirst {
            self.viewModel.location.onNext((location!.coordinate.latitude, location!.coordinate.longitude))
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
    }
}
