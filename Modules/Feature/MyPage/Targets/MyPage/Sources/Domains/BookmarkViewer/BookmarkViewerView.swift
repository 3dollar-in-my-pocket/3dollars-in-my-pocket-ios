import UIKit

import Common
import DesignSystem

final class BookmarkViewerView: BaseView {
    let closeButton: UIButton = {
        let button = UIButton()
        let image = Icons.close.image.withRenderingMode(.alwaysTemplate)
        
        button.setImage(image, for: .normal)
        button.tintColor = Colors.systemWhite.color
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        addSubViews([
            closeButton,
            collectionView
        ])
        collectionView.backgroundColor = .clear
    }
    
    override func bindConstraints() {
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
