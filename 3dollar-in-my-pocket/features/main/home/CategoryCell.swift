import UIKit

class CategoryCell: BaseCollectionViewCell {
    
    static let registerId = "\(CategoryCell.self)"
    
    let categoryLabel = UILabel().then {
        $0.text = "닥고약기"
        $0.textColor = .black
    }
    
    override func setup() {
        addSubview(categoryLabel)
    }
    
    override func bindConstraints() {
        categoryLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
}
