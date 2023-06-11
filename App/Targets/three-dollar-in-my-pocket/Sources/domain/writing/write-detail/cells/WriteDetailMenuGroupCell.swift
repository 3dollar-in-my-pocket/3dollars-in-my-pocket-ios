import UIKit

import DesignSystem

final class WriteDetailMenuGroupCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 160)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    private let categoryImageView = UIImageView()
    
    private let categoryNameLabel = UILabel()
    
    private let closeButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setImage(DesignSystemAsset.Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = DesignSystemAsset.Colors.gray0.color
        $0.contentEdgeInsets = .init(top: 6.4, left: 6.4, bottom: 6.4, right: 6.4)
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
            $0.bottom.equalToSuperview()
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