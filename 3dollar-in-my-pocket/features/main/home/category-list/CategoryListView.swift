import UIKit
import GoogleMaps

class CategoryListView: BaseView {
    
    let categoryLabel = UILabel().then {
        $0.text = "텍스트"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 24)
    }
    
    let ratingOrderBtn = UIButton().then {
        $0.setTitle("별점순", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    let reviewOrderBtn = UIButton().then {
        $0.setTitle("리뷰순", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    let mapView = GMSMapView()
    
    let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    
    override func setup() {
        backgroundColor = .white
        addSubViews(categoryLabel, ratingOrderBtn, reviewOrderBtn, mapView, tableView)
    }
    
    override func bindConstraints() {
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.left.equalToSuperview().offset(24)
        }
        
        reviewOrderBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.centerY.equalTo(categoryLabel.snp.centerY)
        }
        
        ratingOrderBtn.snp.makeConstraints { (make) in
            make.right.equalTo(reviewOrderBtn.snp.left).offset(-12)
            make.centerY.equalTo(categoryLabel.snp.centerY)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(categoryLabel.snp.bottom).offset(20)
            make.height.equalTo(153)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(mapView.snp.bottom)
        }
    }
}
