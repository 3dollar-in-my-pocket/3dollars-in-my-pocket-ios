import UIKit
import GoogleMaps

class CategoryListView: BaseView {
    
    let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
    }
    
    let categoryImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_category_fish")
    }
    
    let categoryBungeoppang = UIButton().then {
        $0.setTitle("붕어빵", for: .normal)
        $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
        $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let categoryTakoyaki = UIButton().then {
        $0.setTitle("타코야끼", for: .normal)
        $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
        $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let categoryGyeranppang = UIButton().then {
        $0.setTitle("계란빵", for: .normal)
        $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
        $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let categoryHotteok = UIButton().then {
        $0.setTitle("호떡", for: .normal)
        $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
        $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 24
    }
    
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
        backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        setupNavigationBarShadow()
        categoryStackView.addArrangedSubview(categoryBungeoppang)
        categoryStackView.addArrangedSubview(categoryTakoyaki)
        categoryStackView.addArrangedSubview(categoryGyeranppang)
        categoryStackView.addArrangedSubview(categoryHotteok)
        navigationBar.addSubViews(backBtn, categoryImage, categoryStackView)
        addSubViews(mapView, navigationBar, categoryLabel, ratingOrderBtn, reviewOrderBtn, tableView)
    }
    
    override func bindConstraints() {
        navigationBar.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(145)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(48)
            make.width.height.equalTo(48)
        }
        
        categoryStackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(66)
            make.right.equalToSuperview().offset(-65)
        }
        
        categoryImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn.snp.centerY)
            make.width.height.equalTo(60)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom).offset(-20)
            make.height.equalTo(264)
        }
        
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom).offset(41)
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
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(categoryLabel.snp.bottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = navigationBar.frame
        rectShape.position = navigationBar.center
        rectShape.path = UIBezierPath(roundedRect: navigationBar.frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 16, height: 16)).cgPath

        navigationBar.layer.backgroundColor = UIColor.white.cgColor
        navigationBar.layer.mask = rectShape
    }
    
    private func setupNavigationBarShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: 145), cornerRadius: 16).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.08
        shadowLayer.shadowRadius = 20
        
        navigationBar.layer.insertSublayer(shadowLayer, at: 0)
    }
}
