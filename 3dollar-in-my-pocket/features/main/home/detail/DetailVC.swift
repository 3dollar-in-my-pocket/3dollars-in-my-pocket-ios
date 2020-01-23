import UIKit
import GoogleMaps
import Kingfisher

class DetailVC: BaseVC {
    
    private lazy var detailView = DetailView(frame: self.view.frame)
    
    private var viewModel = DetailViewModel()
    private var reviewVC: ReviewModalVC?
    private var myLocationFlag = false
    var storeId: Int!
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
    }
    
    override func bindViewModel() {
        viewModel.store.subscribe { [weak self] (store) in
            self?.detailView.tableView.reloadData()
        }.disposed(by: disposeBag)
        
        detailView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func getStoreDetail(latitude: Double, longitude: Double) {
        StoreService.getStoreDetail(storeId: storeId, latitude: latitude, longitude: longitude) { [weak self] (response) in
            switch response.result {
            case .success(let store):
                self?.detailView.titleLabel.text = store.storeName
                self?.viewModel.store.onNext(store)
            case .failure(let error):
                AlertUtils.show(controller: self, title: "getStoreDetail error", message: error.localizedDescription)
            }
        }
    }
    
    private func moveToMyLocation(latitude: Double, longitude: Double) {
        guard let shopInfoCell = self.detailView.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ShopInfoCell else {
            return
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        
        shopInfoCell.mapView.animate(to: camera)
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
            if let store = try? self.viewModel.store.value() {
                return store.reviews.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let store = try? self.viewModel.store.value() {
            if indexPath.section == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopInfoCell.registerId, for: indexPath) as? ShopInfoCell else {
                    return BaseTableViewCell()
                }
                cell.reviewBtn.rx.tap.bind { [weak self] (_) in
                    self?.reviewVC = ReviewModalVC.instance().then {
                        $0.deleagete = self
                        $0.storeId = self?.storeId
                    }
                    self?.detailView.addBgDim()
                    self?.present(self!.reviewVC!, animated: true)
                }.disposed(by: disposeBag)
                
                cell.modifyBtn.rx.tap.bind { [weak self] in
                    if let vc = self,
                        let store = try! vc.viewModel.store.value(){
                        self?.navigationController?.pushViewController(ModifyVC.instance(store: store), animated: true)
                    }
                }.disposed(by: disposeBag)
                
                cell.mapBtn.rx.tap.bind { [weak self] in
                    self?.myLocationFlag = true
                    self?.locationManager.startUpdatingLocation()
                }.disposed(by: disposeBag)
                
                cell.setRank(rank: store.rating)
                if !(store.images.isEmpty) {
                    cell.setImage(url: store.images[0].url, count: store.images.count)
                }
                cell.setMarker(latitude: store.latitude!, longitude: store.longitude!)
                cell.setCategory(category: store.category!)
                cell.setMenus(menus: store.menus)
                cell.setDistance(distance: store.distance)
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.registerId, for: indexPath) as? ReviewCell else {
                    return BaseTableViewCell()
                }
                
                cell.bind(review: store.reviews[indexPath.row])
                return cell
            }
        } else {
            return BaseTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return ReviewHeaderView().then {
                if let store = try? self.viewModel.store.value() {
                    $0.setReviewCount(count: store.reviews.count)
                }
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
        
        if myLocationFlag {
            self.moveToMyLocation(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        } else {
            self.getStoreDetail(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
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
}
