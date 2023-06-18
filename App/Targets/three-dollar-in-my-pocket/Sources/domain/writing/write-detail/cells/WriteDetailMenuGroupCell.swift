import UIKit

import DesignSystem

final class WriteDetailMenuGroupCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 160 + topOffset)
        static let topOffset: CGFloat = 12
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    private let categoryImageView = UIImageView()
    
    private let categoryNameLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        $0.textColor = DesignSystemAsset.Colors.gray90.color
    }
    
    let closeButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.cornerRadius = 10
        $0.setImage(DesignSystemAsset.Icons.close.image.withTintColor(DesignSystemAsset.Colors.gray0.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    lazy var menuCollectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.register([WriteDetailMenuItemCell.self])
        $0.dataSource = self
    }
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.gray0.color
        containerView.addSubViews([
            categoryImageView,
            categoryNameLabel,
            closeButton,
            menuCollectionView
        ])
        contentView.addSubview(containerView)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Layout.topOffset)
        }
        
        categoryImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.width.height.equalTo(24)
        }
        
        categoryNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryImageView)
            $0.left.equalTo(categoryImageView.snp.right).offset(4)
        }
        
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-12)
            $0.centerY.equalTo(categoryImageView)
            $0.width.height.equalTo(20)
        }
        
        menuCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-12)
            $0.top.equalTo(categoryImageView.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(category: PlatformStoreCategory) {
        categoryImageView.setImage(urlString: category.imageUrl)
        categoryNameLabel.text = category.name
    }
    
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = WriteDetailMenuItemCell.Layout.size
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        return layout
    }
}

extension WriteDetailMenuGroupCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WriteDetailMenuItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        return cell
    }
}
