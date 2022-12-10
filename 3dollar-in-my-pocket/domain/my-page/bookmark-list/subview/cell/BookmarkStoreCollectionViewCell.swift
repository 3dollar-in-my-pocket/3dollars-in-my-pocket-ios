import UIKit

final class BookmarkStoreCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(BookmarkStoreCollectionViewCell.self)"
    static let height: CGFloat = 102
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let categoryImageView = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
        $0.text = "강남역 0번 출구"
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    private let categoriesLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
        $0.text = "#붕어빵 #땅콩과자 #호떡"
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.categoryImageView,
            self.titleLabel,
            self.categoriesLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.categoryImageView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
            make.bottom.equalTo(self.containerView).offset(-16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.categoryImageView).offset(8)
            make.top.equalTo(self.categoryImageView).offset(2)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.categoriesLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.right.equalTo(self.titleLabel)
        }
    }
}
