import UIKit

import Base

final class HomeCategoryCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(HomeCategoryCollectionViewCell.self)"
    static let itemSize = CGSize(width: 55, height: 28)
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 14
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.08
        $0.layer.shadowColor = UIColor.black.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray40()
        $0.text = "붕어빵"
    }
    
    override func setup() {
        self.clipsToBounds = false
        self.addSubViews([
            self.containerView,
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalTo(self.titleLabel).offset(12)
            make.right.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView).offset(12)
        }
    }
}
