import UIKit

import Common
import DesignSystem
import Model

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
        
        button.setImage(Images.iconDelete.image, for: .normal)
        button.alpha = 0
        return button
    }()
    
    private let arrowImage: UIImageView = {
        let imageView = UIImageView()
        let arrowImage = Icons.arrowRight.image.withRenderingMode(.alwaysTemplate)
        imageView.image = arrowImage
        imageView.tintColor = Colors.systemWhite.color
        imageView.isHidden = true
        return imageView
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
            deleteButton,
            arrowImage
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
            $0.top.equalTo(categoriesLabel.snp.bottom).offset(2)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(containerView).offset(-16)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        arrowImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(containerView).offset(-16)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }
    }
    
    func bind(_ viewModel: BookmarkStoreCellViewModel, index: Int) {
        deleteButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapDelete)
            .store(in: &cancellables)
        
        viewModel.input.index.send(index)
        
        bindStore(viewModel.output.store)
        
        viewModel.output.isDeleteMode
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkStoreCell, isDeleteModel: Bool) in
                owner.setDeleteMode(isDeleteMode: isDeleteModel)
            }
            .store(in: &cancellables)
    }
    
    func bind(store: StoreResponse) {
        bindStore(store)
        arrowImage.isHidden = false
    }
    
    private func bindStore(_ store: StoreResponse) {
        categoryImageView.setImage(urlString: store.categories.first?.imageUrl)
        categoriesLabel.text = store.categoriesString
        titleLabel.text = store.storeName
    }
    
    private func setDeleteMode(isDeleteMode: Bool) {
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.deleteButton.alpha = isDeleteMode ? 1 : 0
        }
    }
}
