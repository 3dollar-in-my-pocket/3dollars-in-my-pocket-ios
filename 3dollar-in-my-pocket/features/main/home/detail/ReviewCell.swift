import UIKit

class ReviewCell: BaseTableViewCell {
    
    static let registerId = "\(ReviewCell.self)"
    
    let nameLabel = UILabel().then {
        $0.text = "익명"
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    override func setup() {
        addSubview(nameLabel)
        selectionStyle = .none
    }
    
    override func bindConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
