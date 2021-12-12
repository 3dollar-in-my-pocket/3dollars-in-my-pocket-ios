import UIKit

final class MyMedalView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_white(), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = R.string.localization.my_medal_title()
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        
        layout.estimatedItemSize = MedalCollectionCell.size
        layout.minimumInteritemSpacing = 17
        layout.minimumLineSpacing = 20
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 62)
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.register(
            MyMedalCollectionCell.self,
            forCellWithReuseIdentifier: MyMedalCollectionCell.registerId
        )
        $0.register(
            MedalCollectionCell.self,
            forCellWithReuseIdentifier: MedalCollectionCell.registerId
        )
        $0.register(
            MedalHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MedalHeaderView.registerId
        )
        $0.contentInset = UIEdgeInsets(top: 26, left: 24, bottom: 24, right: 24)
    }
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
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
}