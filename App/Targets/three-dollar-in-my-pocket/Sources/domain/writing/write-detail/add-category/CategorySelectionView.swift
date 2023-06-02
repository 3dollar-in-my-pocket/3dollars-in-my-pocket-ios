import UIKit

import DesignSystem

final class CategorySelectionView: BaseView {
    enum Layout {
        static let itemSpace: CGFloat = 16
        static let lineSpace: CGFloat = 12
    }
    
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let titleLabel = UILabel().then {
        $0.text = ThreeDollarInMyPocketStrings.categorySelectionTitle
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
    }
    
    private let multiLabel = UILabel().then {
        $0.text = ThreeDollarInMyPocketStrings.categorySelectionMulti
        $0.textColor = DesignSystemAsset.Colors.mainPink.color
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
    }
    
    lazy var categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = true
    }
    
    let selectButton = Button.Normal(size: .h52, text: ThreeDollarInMyPocketStrings.categorySelectionOk).then {
        $0.isEnabled = false
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            backgroundButton,
            containerView,
            titleLabel,
            multiLabel,
            categoryCollectionView,
            selectButton
        ])
    }
    
    override func bindConstraints() {
        backgroundButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel).offset(-24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalTo(categoryCollectionView.snp.top).offset(-17)
        }
        
        multiLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.left.equalTo(titleLabel.snp.right).offset(12)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(selectButton.snp.top).offset(-28)
            $0.height.equalTo(0)
        }
        
        selectButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }
    
    func updateCollectionViewHeight(itemCount: Int) {
        let row = CGFloat(itemCount / 5 + 1)
        let height = (CategorySelectionCell.Layout.size.height * row) + (Layout.lineSpace * (row - 1))
        
        categoryCollectionView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
        layoutIfNeeded()
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CategorySelectionCell.Layout.size
        layout.minimumInteritemSpacing = Layout.itemSpace
        layout.minimumLineSpacing = Layout.lineSpace
        
        return layout
    }
}
