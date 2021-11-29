import UIKit

final class RegisteredStoreCell: BaseTableViewCell {
    
    static let registerId = "\(RegisteredStoreCell.self)"
    static let size = CGSize(
        width: UIScreen.main.bounds.width - 48,
        height: 120
    )
    
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 24
    }
    
    private let categoryImage = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
    }
    
    private let categoriesLabel = UILabel().then {
        $0.textColor = R.color.gray50()
        $0.font = .regular(size: 12)
    }
    
    private let starImage = UIImageView().then {
        $0.image = R.image.ic_star_white()
    }
    
    private let rankLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .medium(size: 14)
    }
    
    private let bedgeView = VisitBedgeView()
    
    
    override func setup() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.addSubViews([
            self.containerView,
            self.categoryImage,
            self.titleLabel,
            self.categoriesLabel,
            self.starImage,
            self.rankLabel,
            self.bedgeView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.size.equalTo(Self.size)
        }
        
        self.categoryImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.top.equalTo(self.containerView).offset(16)
            make.width.height.equalTo(40)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(16)
            make.left.equalTo(self.categoryImage.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
        }
        
        self.categoriesLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.starImage.snp.makeConstraints { make in
            make.bottom.equalTo(self.containerView).offset(-21)
            make.left.equalTo(self.titleLabel)
            make.width.height.equalTo(16)
        }
        
        self.rankLabel.snp.makeConstraints { make in
            make.left.equalTo(self.starImage.snp.right).offset(4)
            make.centerY.equalTo(self.starImage)
        }
        
        self.bedgeView.snp.makeConstraints { make in
            make.bottom.equalTo(self.containerView).offset(-16)
            make.right.equalTo(self.containerView).offset(-14)
        }
    }
}
