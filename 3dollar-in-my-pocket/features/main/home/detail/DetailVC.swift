import UIKit
import GoogleMaps
import Kingfisher

class DetailVC: BaseVC {
    
    private lazy var detailView = DetailView(frame: self.view.frame)
    
    private var reviewVC: ReviewModalVC?
    
    var storeId: Int!
    
    var reviews: [Review] = []
    
    var locationManager = CLLocationManager()
    
    static func instance(storeId: Int) -> DetailVC {
        return DetailVC.init(nibName: nil, bundle: nil).then {
            $0.storeId = storeId
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = detailView
        
        detailView.tableView.delegate = self
        detailView.tableView.dataSource = self
        detailView.tableView.register(ShopInfoCell.self, forCellReuseIdentifier: ShopInfoCell.registerId)
        detailView.tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.registerId)
        
        setupLocationManager()
        getStoreDetail()
    }
    
    override func bindViewModel() {
        detailView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func getStoreDetail() {
        StoreService.getStoreDetail(storeId: storeId) { [weak self] (response) in
            switch response.result {
            case .success(let store):
                self?.detailView.titleLabel.text = store.storeName
                self?.setShopInfo(store: store)
                self?.reviews = store.reviews
                break
            case .failure(let error):
                AlertUtils.show(controller: self, title: "getStoreDetail error", message: error.localizedDescription)
            }
        }
    }
    
    private func setShopInfo(store: Store) {
        let camera = GMSCameraPosition.camera(withLatitude: store.latitude!, longitude: store.longitude!, zoom: 15)
        
        if let shopInfoCell = self.detailView.tableView.cellForRow(at: IndexPath.init(item: 0, section: 0)) as? ShopInfoCell {
            // set marker
            shopInfoCell.mapView.isMyLocationEnabled = true
            shopInfoCell.mapView.camera = camera
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: store.latitude!, longitude: store.longitude!)
            marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_on")!, scaledToSize: CGSize.init(width: 16, height: 16))
            marker.map = shopInfoCell.mapView
            
            // Set ranking
            shopInfoCell.setRank(rank: store.rating)
            
            // Set image
            if !(store.images.isEmpty) {
                shopInfoCell.setImage(url: store.images[0].url, count: store.images.count)
            }
            
            // Set category
            shopInfoCell.setCategory(category: store.category!)
            shopInfoCell.setMenus(menus: store.menus)
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

extension DetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopInfoCell.registerId, for: indexPath) as? ShopInfoCell else {
                return BaseTableViewCell()
            }
            
            cell.reviewBtn.rx.tap.bind { [weak self] (_) in
                self?.reviewVC = ReviewModalVC.instance().then {
                    $0.deleagete = self
                }
                self?.detailView.addBgDim()
                self?.present(self!.reviewVC!, animated: true)
            }.disposed(by: disposeBag)
            
            cell.mapBtn.rx.tap.bind { [weak self] in
                self?.locationManager.startUpdatingLocation()
            }.disposed(by: disposeBag)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.registerId, for: indexPath) as? ReviewCell else {
                return BaseTableViewCell()
            }
            
            cell.bind(review: self.reviews[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return ReviewHeaderView().then {
                $0.setReviewCount(count: self.reviews.count)
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 70
        } else {
            return 0
        }
    }
}

extension DetailVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 15)
        
        
        if let shopInfoCell = self.detailView.tableView.cellForRow(at: IndexPath.init(item: 0, section: 0)) as? ShopInfoCell {
            // set marker
            shopInfoCell.mapView.animate(to: camera)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
    }
}

extension DetailVC: ReviewModalDelegate {
    func onTapClose() {
        reviewVC?.dismiss(animated: true, completion: nil)
        self.detailView.removeBgDim()
    }
    
    func onTapRegister() {
        reviewVC?.dismiss(animated: true, completion: nil)
        self.detailView.removeBgDim()
    }
}
