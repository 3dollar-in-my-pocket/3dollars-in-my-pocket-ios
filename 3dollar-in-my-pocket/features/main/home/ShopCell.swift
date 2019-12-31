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
    
    let bungeoppangImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_fish_off")
        $0.contentMode = .scaleAspectFit
    }
    
    override func setup() {
        layer.cornerRadius = 16
        backgroundColor = UIColor.init(r: 251, g: 251, b: 251)
        addSubViews(distanceLabel, bungeoppangImage)
    }
    
    override func bindConstraints() {
        distanceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(56)
            make.height.equalTo(25)
        }
        
        bungeoppangImage.snp.makeConstraints { (make) in
            make.top.equalTo(distanceLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
    }
    
    func setSelected(isSelected: Bool) {
        if isSelected {
            backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        } else {
            backgroundColor = UIColor.init(r: 251, g: 251, b: 251)
        }
    }
    
    private func setupShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shadowLayer.fillColor = UIColor.init(r: 251, g: 251, b: 251).cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 15, height: 20)
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.shadowRadius = 10
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
