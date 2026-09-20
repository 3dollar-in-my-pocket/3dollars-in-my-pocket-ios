import UIKit

import Common
import DesignSystem

final class CategorySelectionView: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 20)
        label.text = Strings.categorySelectionTitle
        
        return label
    }()
    
    private let multiLabel: UILabel = {
        let multiLabel = UILabel()
        multiLabel.text = Strings.categorySelectionMulti
        multiLabel.textColor = Colors.mainPink.color
        multiLabel.font = Fonts.bold.font(size: 12)
        return multiLabel
    }()
    
    lazy var categoryCollectionView: UICollectionView = {
        let categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    )
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsVerticalScrollIndicator = false
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.allowsMultipleSelection = true
        return categoryCollectionView
    }()
    
    let selectButton: Button.Normal = {
        let selectButton = Button.Normal(size: .h52, text: Strings.categorySelectionOk)
        selectButton.isEnabled = false
        return selectButton
    }()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            titleLabel,
            multiLabel,
            categoryCollectionView,
            selectButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
        }
        
        multiLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(12)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.bottom.equalTo(selectButton.snp.top).offset(-28)
        }
        
        selectButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .absolute(CategorySelectionCell.size.width),
                heightDimension: .absolute(CategorySelectionCell.size.height)
            ))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(CategorySelectionCell.size.height)
            ), subitems: [item])
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(12)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
            section.interGroupSpacing = 12
            section.boundarySupplementaryItems = [ .init(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(CategorySelectionHeaderView.estimatedHeight)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )]
            
            return section
        }
    }
}
