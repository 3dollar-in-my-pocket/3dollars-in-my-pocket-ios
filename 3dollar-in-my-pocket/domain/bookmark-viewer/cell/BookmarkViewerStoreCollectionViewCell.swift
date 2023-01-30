import UIKit

final class BookmarkViewerStoreCollectionViewCell: BaseCollectionViewCell {
    static let height: CGFloat = 92
    
    private let containerView = UIView().then {
        $0.backgroundColor = Color.gray95
        $0.layer.cornerRadius = 15
    }
    
    private let categoryImageView = UIImageView().then {
        $0.backgroundColor = .green
    }
    
    private let storeTitleLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
        $0.text = "강남역 0번 출구"
        $0.textAlignment = .left
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = Color.gray30
        $0.text = "#붕어빵 #땅콩과자 #호떡"
        $0.textAlignment = .left
    }
    
    private let rightArrowImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_right_arrow")
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.categoryImageView,
            self.storeTitleLabel,
            self.categoryLabel,
            self.rightArrowImageView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        self.categoryImageView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
            make.bottom.equalTo(self.containerView).offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        self.storeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(20)
            make.left.equalTo(self.categoryImageView.snp.right).offset(8)
            make.right.equalTo(self.rightArrowImageView.snp.left).offset(-4)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.left.equalTo(self.storeTitleLabel)
            make.right.equalTo(self.storeTitleLabel)
            make.top.equalTo(self.storeTitleLabel.snp.bottom).offset(8)
        }
        
        self.rightArrowImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(14)
            make.height.equalTo(14)
        }
    }
}
