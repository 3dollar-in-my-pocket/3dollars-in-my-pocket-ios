import UIKit

final class BookmarkOverviewCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(BookmarkOverviewCollectionViewCell.self)"
    static let height: CGFloat = 256
    
    private let contaienrView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.layer.masksToBounds = true
        $0.backgroundColor = Color.gray95
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .white
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = Color.gray50
        $0.numberOfLines = 0
    }
    
    let editButton = UIButton().then {
        $0.setTitle("bookmark_list_edit_folder".localized, for: .normal)
        $0.backgroundColor = Color.gray80
        $0.setTitleColor(Color.gray20, for: .normal)
        $0.titleLabel?.font = .bold(size: 12)
        $0.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        $0.layer.cornerRadius = 15
    }
    
    override func setup() {
        self.addSubViews([
            self.contaienrView,
            self.titleLabel,
            self.descriptionLabel,
            self.editButton
        ])
    }
    
    override func bindConstraints() {
        self.contaienrView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contaienrView).offset(24)
            make.top.equalTo(self.contaienrView).offset(26)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(self.contaienrView).offset(-24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
        }
        
        self.editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.contaienrView).offset(-18)
            make.height.equalTo(30)
        }
    }
    
    func bind(bookmarkFolder: BookmarkFolder) {
        self.titleLabel.text = bookmarkFolder.name
        self.descriptionLabel.text = bookmarkFolder.introduction
    }
}
