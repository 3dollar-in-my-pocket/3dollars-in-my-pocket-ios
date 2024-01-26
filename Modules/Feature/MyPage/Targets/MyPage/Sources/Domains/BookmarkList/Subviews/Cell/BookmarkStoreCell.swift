import UIKit

import Common
import DesignSystem

final class BookmarkStoreCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 80
    }
    
    private let containerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray95.color
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let categoryImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.bold.font(size: 15)
        label.textColor = Colors.systemWhite.color
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let categoriesLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray40.color
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        
//        button.setImage(nil, for: .normal)
        button.alpha = 0
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        categoryImageView.image = nil
    }
    
    override func setup() {
        addSubViews([
            containerView,
            categoryImageView,
            titleLabel,
            categoriesLabel,
            deleteButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
        }
        
        categoryImageView.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.bottom.equalTo(containerView).offset(-16)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        categoriesLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            $0.top.equalTo(categoryImageView)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(categoriesLabel)
            $0.top.equalTo(categoriesLabel).offset(2)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(containerView).offset(-16)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
//    func bind(store: StoreProtocol) {
//        guard let platformStore = store as? PlatformStore else { return }
//        
//        self.categoryImageView.setImage(
//            urlString: platformStore.categories.first?.imageUrl ?? ""
//        )
//        self.categoriesLabel.text = platformStore.categoriesString
//        self.titleLabel.text = platformStore.name
//    }
//    
//    fileprivate func setDeleteMode(isDeleteMode: Bool) {
//        self.containerView.snp.updateConstraints { make in
//            make.right.equalToSuperview().offset(isDeleteMode ? -64 : -24)
//        }
//        UIView.transition(with: self, duration: 0.3) { [weak self] in
//            self?.layoutIfNeeded()
//            self?.deleteButton.alpha = isDeleteMode ? 1 : 0
//        }
//    }
}
