import UIKit

class RegisterCell: BaseCollectionViewCell {
    
    static let registerId = "\(RegisterCell.self)"
    
    let categoryImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_card_bungeoppang_on")
    }
    
    let titleLabel = UILabel().then {
        $0.text = "강남역 2번출구 앞"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let rankingView = RankingView()
    
    let frontImage = UIImageView().then {
        $0.image = UIImage.init(named: "ic_front_white")
        $0.isHidden = true
    }
    
    let totalLabel = UILabel().then {
        $0.text = "전체보기"
        $0.textColor = UIColor.init(r: 151, g: 151, b: 151)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.isHidden = true
    }
    
    
    override func setup() {
        backgroundColor = UIColor.init(r: 74, g: 74, b: 74)
        layer.cornerRadius = 16
        addSubViews(categoryImage, titleLabel, rankingView, frontImage, totalLabel)
        setupShadow()
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(120)
            make.height.equalTo(80)
        }
        
        rankingView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-18)
            make.height.equalTo(20)
        }
        
        frontImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
            make.top.equalToSuperview().offset(48)
        }
        
        totalLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(frontImage.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(rankingView)
            make.top.equalTo(categoryImage.snp.bottom).offset(11)
        }
    }
    
    func bind(store: Store?) {
        if let store = store {
            switch store.category! {
            case .BUNGEOPPANG:
                categoryImage.image = UIImage.init(named: "img_card_bungeoppang_on")
            case .GYERANPPANG:
                categoryImage.image = UIImage.init(named: "img_card_gyeranppang_on")
            case.HOTTEOK:
                categoryImage.image = UIImage.init(named: "img_card_hotteok_on")
            case.TAKOYAKI:
                categoryImage.image = UIImage.init(named: "img_card_takoyaki_on")
            }
            titleLabel.text = store.storeName
            rankingView.setRank(rank: store.rating)
            categoryImage.isHidden = false
            titleLabel.isHidden = false
            rankingView.isHidden = false
            frontImage.isHidden = true
            totalLabel.isHidden = true
        } else {
            categoryImage.isHidden = true
            titleLabel.isHidden = true
            rankingView.isHidden = true
            frontImage.isHidden = false
            totalLabel.isHidden = false
        }
    }
    
    func setSelected(isSelected: Bool) {
        if let shadowLayer = layer.sublayers?.first as? CAShapeLayer {
            if isSelected {
                shadowLayer.fillColor = UIColor.init(r: 28, g: 28, b: 28).cgColor
            } else {
                shadowLayer.fillColor = UIColor.init(r: 251, g: 251, b: 251).cgColor
            }
        }
    }
    
    private func setupShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shadowLayer.fillColor = UIColor.init(r: 74, g: 74, b: 74).cgColor
        shadowLayer.masksToBounds = false
        shadowLayer.shouldRasterize = true
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 5, height: 10)
        shadowLayer.shadowOpacity = 0.24
        shadowLayer.shadowRadius = 5
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
