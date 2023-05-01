import UIKit

final class HomeCategoryCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(HomeCategoryCollectionViewCell.self)"
    static let itemSize = CGSize(width: 55, height: 28)
    private var storeType: StoreType = .streetFood
    
    override var isSelected: Bool {
        didSet {
            self.setSelected(isSelected: self.isSelected)
        }
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 14
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.08
        $0.layer.shadowColor = UIColor.black.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = Color.gray40
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
    
    func bind(category: Categorizable, storeType: StoreType) {
        self.titleLabel.text = category.name
        self.storeType = storeType
    }
    
    private func setSelected(isSelected: Bool) {
        if isSelected {
            switch self.storeType {
            case .streetFood:
                self.containerView.backgroundColor = Color.pink
                
            case .foodTruck:
                self.containerView.backgroundColor = Color.green
                
            case .unknown:
                break
            }
            self.titleLabel.textColor = .white
        } else {
            self.containerView.backgroundColor = .white
            self.titleLabel.textColor = Color.gray40
        }
    }
}
