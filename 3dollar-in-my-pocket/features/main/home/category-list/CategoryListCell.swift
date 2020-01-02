import UIKit

class CategoryListCell: BaseTableViewCell {
    
    static let registerId = "\(CategoryListCell.self)"
    
    let categoryImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_shop_fish")
    }
    
    let titleLabel = UILabel().then {
        $0.text = "강남역 10번 출구"
        $0.textColor = UIColor.init(r: 44, g: 44, b: 44)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let distanceLabel = UILabel().then {
        $0.text = "10m"
        $0.textColor = UIColor.init(r: 28, g: 28, b: 28)
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
    }
    
    override func setup() {
        backgroundColor = .white
        selectionStyle = .none
        addSubViews(categoryImage, titleLabel, distanceLabel)
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(40)
            make.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryImage.snp.centerY)
            make.left.equalTo(categoryImage.snp.right).offset(16)
        }
        
        distanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryImage.snp.centerY)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func setBottomRadius() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
