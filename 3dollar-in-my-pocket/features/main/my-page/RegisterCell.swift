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
    
    
    override func setup() {
        backgroundColor = UIColor.init(r: 74, g: 74, b: 74)
        layer.cornerRadius = 16
        addSubViews(categoryImage, titleLabel, rankingView)
        setupShadow()
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(115)
            make.height.equalTo(73)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(categoryImage.snp.bottom).offset(11)
        }
        
        rankingView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-18)
            make.height.equalTo(20)
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
