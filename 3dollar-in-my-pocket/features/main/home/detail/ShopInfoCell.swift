import UIKit
import GoogleMaps
import RxSwift

class ShopInfoCell: BaseTableViewCell {
    
    static let registerId = "\(ShopInfoCell.self)"
    
    let mapView = GMSMapView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let mapBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_location"), for: .normal)
    }
    
    let titleContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    let profileImage = UIImageView().then {
        $0.backgroundColor = UIColor.init(r: 217, g: 217, b: 217)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    let emptyImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_card_bungeoppang_off")
        $0.contentMode = .scaleAspectFit
    }
    
    let distanceLabel = UILabel().then {
        let text = "50m이내에 위치한\n음식점입니다."
        let attributedText = NSMutableAttributedString(string: text)
        
        attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 22)!, range: (text as NSString).range(of: "50m이내"))
        attributedText.addAttribute(.kern, value: -1.6, range: NSMakeRange(0, text.count-1))
        $0.textColor = UIColor.init(r: 55, g: 55, b: 55)
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 20)
        $0.attributedText = attributedText
        $0.numberOfLines = 0
    }
    
    let star1 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_big_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_big_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star2 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_big_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_big_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star3 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_big_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_big_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star4 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_big_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_big_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let star5 = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_star_big_on"), for: .selected)
        $0.setImage(UIImage.init(named: "ic_star_big_off"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.backgroundColor = .clear
        $0.spacing = 2
    }
    
    let rankingLabel = UILabel().then {
        $0.text = "3.8점"
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
    }
    
    let categoryLabel = UILabel().then {
        $0.text = "카테고리"
        $0.textColor = UIColor.init(r: 44, g: 44, b: 44)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let categoryValueLabel = UILabel().then {
        $0.text = "붕어빵"
        $0.textColor = UIColor.init(r: 44, g: 44, b: 44)
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
    }
    
    let menuLabel = UILabel().then {
        $0.text = "상세메뉴"
        $0.textColor = UIColor.init(r: 44, g: 44, b: 44)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let menuNameLabel = UILabel().then {
        $0.text = "등록된 정보가 없습니다"
        $0.textColor = UIColor.init(r: 137, g: 137, b: 137)
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.numberOfLines = 0
    }
    
    let menuPriceLabel = UILabel().then {
        $0.textColor = UIColor.init(r: 109, g: 109, b: 109)
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.numberOfLines = 0
    }
    
    let reviewBtn = UIButton().then {
        $0.setTitle("리뷰 남기기", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setTitleColor(UIColor.init(r: 153, g: 153, b: 153), for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 153, g: 153, b: 153).cgColor
    }
    
    let modifyBtn = UIButton().then {
        $0.setTitle("가게 정보 수정하기", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setTitleColor(UIColor.init(r: 153, g: 153, b: 153), for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 153, g: 153, b: 153).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setup() {
        selectionStyle = .none
        stackView.addArrangedSubview(star1)
        stackView.addArrangedSubview(star2)
        stackView.addArrangedSubview(star3)
        stackView.addArrangedSubview(star4)
        stackView.addArrangedSubview(star5)
        titleContainer.addSubViews(profileImage, emptyImage, distanceLabel, stackView, rankingLabel)
        addSubViews(mapView, mapBtn, titleContainer, categoryLabel, categoryValueLabel, menuLabel, menuNameLabel, menuPriceLabel, reviewBtn, modifyBtn)
        setupContainerShadow()
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(336)
        }
        
        mapBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(mapView.snp.bottom).offset(-84)
            make.width.height.equalTo(40)
        }
        
        titleContainer.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(mapView.snp.bottom)
            make.height.equalTo(120)
        }
        
        profileImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(88)
        }
        
        emptyImage.snp.makeConstraints { (make) in
            make.center.equalTo(profileImage.snp.center)
            make.height.equalTo(37)
        }
        
        distanceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(profileImage.snp.right).offset(24)
        }
        
        rankingLabel.snp.makeConstraints { (make) in
            make.right.equalTo(distanceLabel.snp.right)
            make.top.equalTo(distanceLabel.snp.bottom).offset(10)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.left.equalTo(distanceLabel.snp.left)
            make.centerY.equalTo(rankingLabel.snp.centerY)
        }
        
        categoryLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(titleContainer.snp.bottom).offset(24)
        }
        
        categoryValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryLabel.snp.centerY)
            make.left.equalTo(categoryLabel.snp.right).offset(16)
        }
        
        menuLabel.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.top.equalTo(categoryLabel.snp.bottom).offset(3)
        }
        
        menuNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(menuLabel)
            make.left.equalTo(menuLabel.snp.right).offset(16)
        }
        
        menuPriceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(menuLabel)
            make.left.equalTo(menuNameLabel.snp.right).offset(16)
        }
        
        reviewBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(menuNameLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalTo(160 * UIScreen.main.bounds.width / 375)
            make.height.equalTo(48 * UIScreen.main.bounds.width / 375)
        }
        
        modifyBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(reviewBtn.snp.centerY)
            make.width.equalTo(160 * UIScreen.main.bounds.width / 375)
            make.height.equalTo(48 * UIScreen.main.bounds.width / 375)
        }
    }
    
    private func setupContainerShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 120), cornerRadius: 12).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 8.0, height: 8.0)
        shadowLayer.shadowOpacity = 0.06
        shadowLayer.shadowRadius = 5
        
        titleContainer.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func setMarker(latitude: Double, longitude: Double) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        
        // set marker
        mapView.isMyLocationEnabled = true
        mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_on")!, scaledToSize: CGSize.init(width: 16, height: 16))
        marker.map = mapView
    }
    
    private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func setRank(rank: Float) {
        let roundedRank = Int(rank.rounded())
        
        for index in 0...stackView.arrangedSubviews.count - 1 {
            if let star = stackView.arrangedSubviews[index] as? UIButton {
                star.isSelected = index < roundedRank
            }
        }
        rankingLabel.text = "\(rank)"
    }
    
    func setImage(url: String, count: Int) {
        profileImage.kf.setImage(with: URL(string: url))
        emptyImage.isHidden = true
    }
    
    func setCategory(category: StoreCategory) {
        switch category {
        case .BUNGEOPPANG:
            categoryValueLabel.text = "붕어빵"
            emptyImage.image = UIImage.init(named: "img_detail_bungeoppang")
        case .GYERANPPANG:
            categoryValueLabel.text = "계란빵"
            emptyImage.image = UIImage.init(named: "img_detail_gyeranppang")
        case .HOTTEOK:
            categoryValueLabel.text = "호떡"
            emptyImage.image = UIImage.init(named: "img_detail_hotteok")
        case .TAKOYAKI:
            categoryValueLabel.text = "타코야끼"
            emptyImage.image = UIImage.init(named: "img_detail_takoyaki")
        }
    }
    
    func setMenus(menus: [Menu]) {
        if menus.isEmpty {
            menuNameLabel.text = "등록된 정보가 없습니다"
            menuNameLabel.textColor = UIColor.init(r: 137, g: 137, b: 137)
        } else {
            var name = ""
            var price = ""
            
            for menu in menus {
                name.append("\(menu.name!)\n")
                price.append("\(menu.price!)\n")
            }
            menuNameLabel.text = name
            menuNameLabel.textColor = UIColor.init(r: 28, g: 28, b: 28)
            menuPriceLabel.text = price
        }
    }
    
    func setDistance(distance: Int) {
        let text = "\(distance)m이내에 위치한\n음식점입니다."
        let attributedText = NSMutableAttributedString(string: text)

        attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 22)!, range: (text as NSString).range(of: "\(distance)m이내"))
        attributedText.addAttribute(.kern, value: -1.6, range: NSMakeRange(0, text.count-1))
        
        distanceLabel.attributedText = attributedText
    }
}
