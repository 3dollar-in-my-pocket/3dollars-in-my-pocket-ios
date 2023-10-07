import UIKit

import Common
import DesignSystem

final class ReviewListView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.arrowLeft.image.withTintColor(Colors.gray100.color), for: .normal)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ReviewList.title
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    let subtabStackView = SubtabStackView()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    let writeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.mainPink.color
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.setTitle(Strings.ReviewList.writeReview, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        
        return button
    }()
    
    private let buttonBottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        
        return view
    }()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            backButton,
            titleLabel,
            subtabStackView,
            collectionView,
            writeButton,
            buttonBottomView
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        subtabStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(backButton.snp.bottom).offset(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtabStackView.snp.bottom).offset(12)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(writeButton.snp.top)
        }
        
        buttonBottomView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        writeButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(buttonBottomView.snp.top)
            $0.height.equalTo(64)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(ReviewListCell.Layout.estimatedHeight)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(ReviewListCell.Layout.estimatedHeight)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = .zero
            
            return section
        }
        
        return layout
    }
}
