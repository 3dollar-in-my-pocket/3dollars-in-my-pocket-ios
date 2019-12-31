import UIKit
import GoogleMaps

class DetailView: BaseView {
    
    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.alwaysBounceVertical = true
    }
    
    let containerView = UIView()
    
    let titleView = UIView().then {
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 8
    }
    
    let mapView = GMSMapView().then {
        $0.isUserInteractionEnabled = false
        $0.contentMode = .scaleAspectFill
    }
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.isPagingEnabled = false
    }
    
    override func setup() {
        containerView.addSubViews(mapView, tableView, titleView)
        scrollView.addSubview(containerView)
        addSubview(scrollView)
    }
    
    override func bindConstraints() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(scrollView)
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.frame.height)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(320)
        }
        
        titleView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(mapView.snp.bottom)
            make.height.equalTo(112)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(mapView.snp.bottom)
        }
    }
}
