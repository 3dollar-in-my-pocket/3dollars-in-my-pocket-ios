import UIKit

class ShopCell: BaseCollectionViewCell {
    
    static let registerId = "\(ShopCell.self)"
    
    let distanceLabel = UILabel().then {
        $0.text = "100m"
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textAlignment = .center
        $0.layer.cornerRadius = 12.5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
    }
    
    let bungeoppangBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "img_fish_off"), for: .normal)
        $0.setImage(UIImage.init(named: "img_fish_on"), for: .selected)
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }
    
    let rankingView = RankingView()
    
    override func setup() {
        layer.cornerRadius = 16
        backgroundColor = UIColor.init(r: 251, g: 251, b: 251)
        setupShadow(isSelected: false)
        addSubViews(distanceLabel, bungeoppangBtn, rankingView)
    }
    
    override func bindConstraints() {
        distanceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(56)
            make.height.equalTo(25)
        }
        
        bungeoppangBtn.snp.makeConstraints { (make) in
            make.top.equalTo(distanceLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
        }
        
        rankingView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-14)
            make.top.equalTo(distanceLabel.snp.bottom).offset(105)
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
        bungeoppangBtn.isSelected = isSelected
        rankingView.setSelected(isSelected: isSelected)
    }
    
    private func setupShadow(isSelected: Bool) {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shadowLayer.fillColor = UIColor.init(r: 251, g: 251, b: 251).cgColor
        shadowLayer.masksToBounds = false
        shadowLayer.shouldRasterize = true
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 15, height: 20)
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.shadowRadius = 10
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
