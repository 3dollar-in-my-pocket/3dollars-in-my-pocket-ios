import UIKit

import RxSwift
import RxCocoa

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
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    private let categoriesLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    
    let deleteButton = UIButton().then {
        $0.setImage(R.image.ic_delete_small(), for: .normal)
        $0.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.categoryImageView.image = nil
        self.titleLabel.text = nil
        self.categoriesLabel.text = nil
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.categoryImageView,
            self.titleLabel,
            self.categoriesLabel,
            self.deleteButton
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
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.categoryImageView.snp.right).offset(8)
            make.top.equalTo(self.categoryImageView).offset(2)
            make.right.equalTo(self.containerView).offset(-16)
        }
        
        self.categoriesLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.right.equalTo(self.titleLabel)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView.snp.right).offset(8)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
    
    func bind(store: StoreProtocol) {
        guard let platformStore = store as? PlatformStore else { return }
        
        self.categoryImageView.setImage(
            urlString: platformStore.categories.first?.imageUrl ?? ""
        )
        self.categoriesLabel.text = platformStore.categoriesString
        self.titleLabel.text = platformStore.name
    }
    
    fileprivate func setDeleteMode(isDeleteMode: Bool) {
        self.containerView.snp.updateConstraints { make in
            make.right.equalToSuperview().offset(isDeleteMode ? -64 : -24)
        }
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
            self?.deleteButton.alpha = isDeleteMode ? 1 : 0
        }
    }
}

extension Reactive where Base: BookmarkStoreCollectionViewCell {
    var isDeleteMode: Binder<Bool> {
        return Binder(self.base) { view, isDeleteMode in
            view.setDeleteMode(isDeleteMode: isDeleteMode)
        }
    }
}
