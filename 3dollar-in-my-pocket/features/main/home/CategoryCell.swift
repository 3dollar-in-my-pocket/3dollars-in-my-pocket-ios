import UIKit

class CategoryCell: BaseCollectionViewCell {
    
    static let registerId = "\(CategoryCell.self)"
    
    let categoryBtn = UIButton().then {
        $0.setTitle("닥고약기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func setup() {
        addSubview(categoryBtn)
    }
    
    override func bindConstraints() {
        categoryBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
}
