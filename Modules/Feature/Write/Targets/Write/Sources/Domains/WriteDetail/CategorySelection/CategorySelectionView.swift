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
    
    private let multiLabel = UILabel().then {
        $0.text = Strings.categorySelectionMulti
        $0.textColor = Colors.mainPink.color
        $0.font = Fonts.bold.font(size: 12)
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
    
    let selectButton = Button.Normal(size: .h52, text: Strings.categorySelectionOk).then {
        $0.isEnabled = false
    }
    
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
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
        }
        
        multiLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.left.equalTo(titleLabel.snp.right).offset(12)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.bottom.equalTo(selectButton.snp.top).offset(-28)
        }
        
        selectButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
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
