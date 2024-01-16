import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common


final class MyMedalView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back_white"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "내 칭호"
        $0.textColor = Colors.systemWhite.color
        $0.font = Fonts.medium.font(size: 16)
    }
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 24, right: 0)
    }
    
    override func setup() {
        self.backgroundColor = Colors.gray100.color
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.collectionView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
            make.width.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.backButton)
            make.centerX.equalToSuperview()
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(10)
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        return layout
    }
}
