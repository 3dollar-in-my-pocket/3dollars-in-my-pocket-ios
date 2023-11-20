import UIKit

import Common
import DesignSystem
import Then

final class StoreDetailView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(
            Icons.arrowLeft.image.withTintColor(Colors.gray100.color),
            for: .normal
        )
    }
    
    let reportnButton = UIButton().then {
        $0.setImage(Icons.deletion.image.withTintColor(Colors.mainRed.color), for: .normal)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    let bottomStickyView = BottomStickyView()
    
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        
        addSubViews([
            backButton,
            reportnButton,
            collectionView,
            bottomStickyView
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        reportnButton.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.right.equalToSuperview().offset(-16)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(bottomStickyView.snp.top)
        }
        
        bottomStickyView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(BottomStickyView.Layout.height)
        }
    }
}
