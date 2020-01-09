import UIKit
import GoogleMaps
import BLTNBoard

class DetailVC: BaseVC {
    
    private lazy var detailView = DetailView(frame: self.view.frame)
    
    
    static func instance() -> DetailVC {
        return DetailVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = detailView
        
//        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
//        
//        detailView.mapView.camera = camera
//        
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
//        marker.title = "닥고약기"
//        marker.snippet = "무름표"
//        marker.map = detailView.mapView
        
        detailView.tableView.delegate = self
        detailView.tableView.dataSource = self
        detailView.tableView.register(ShopInfoCell.self, forCellReuseIdentifier: ShopInfoCell.registerId)
        detailView.tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.registerId)
    }
    
    override func bindViewModel() {
        detailView.backBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
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
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopInfoCell.registerId, for: indexPath) as? ShopInfoCell else {
                return BaseTableViewCell()
            }
            
            cell.reviewBtn.rx.tap.bind { (_) in
                let bulletinManager: BLTNItemManager = {
                    let appearance = BLTNItemAppearance.init().then {
                        $0.actionButtonColor = UIColor.init(r: 238, g: 98, b: 76)
                    }
                    
                    let page = BLTNPageItem(title: "이 가게를\n추천하시나요?").then {
                        $0.actionButtonTitle = "리뷰 등록하기"
                    }
                    page.appearance = appearance
                    
                    
//                    $0.titleLabel.label.font = UIFont.init(name: "SpoqaHanSans-Light", size: 28)
//                    $0.titleLabel.label.numberOfLines = 0
//                    $0.actionButton?.backgroundColor = UIColor.init(r: 238, g: 98, b: 76)
//                    $0.actionButton?.layer.cornerRadius = 14
//                    $0.actionButton?.titleLabel?.textColor = .white
//                    $0.actionButton?.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
                    return BLTNItemManager(rootItem: page)
                }()
                
                bulletinManager.showBulletin(above: self)
            }.disposed(by: disposeBag)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.registerId, for: indexPath) as? ReviewCell else {
                return BaseTableViewCell()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return ReviewHeaderView()
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
