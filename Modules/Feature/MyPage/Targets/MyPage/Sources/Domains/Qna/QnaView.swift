import UIKit

import Common
import DesignSystem

final class QnaView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color)
        
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = Strings.Qna.title
        
        return label
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        
        collectionView.backgroundColor = .clear
        collectionView.register([
            QnaCell.self
        ])
        
        addSubViews([
            backButton,
            titleLabel,
            collectionView
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(
            width: UIUtils.windowBounds.width,
            height: QnaCell.Layout.size.height
        )
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return layout
    }
}

