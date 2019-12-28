import UIKit

class CategoryListCell: BaseTableViewCell {
    
    static let registerId = "\(CategoryListCell.self)"
    
    let profileImage = UIImageView().then {
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    let titleLabel = UILabel().then {
        $0.text = "여기서 드세요!"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 18)
    }
    
    let distanceLabel = UILabel().then {
        $0.text = "10m"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    override func setup() {
        selectionStyle = .none
        addSubViews(profileImage, titleLabel, distanceLabel)
    }
    
    override func bindConstraints() {
        profileImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(54)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileImage.snp.centerY)
            make.left.equalTo(profileImage.snp.right).offset(10)
        }
        
        distanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileImage.snp.centerY)
            make.right.equalToSuperview().offset(-20)
        }
    }
}
