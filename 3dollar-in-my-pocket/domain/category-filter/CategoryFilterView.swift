import UIKit

final class CategoryFilterView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    }
    
    private let topIndicator = UIImageView().then {
        $0.image = R.image.img_top_indicator()
    }
    
    private let titleLabel = UILabel().then {
        let text = R.string.localization.category_title()
        let attributedString = NSMutableAttributedString(string: text)
        let boldTextRange = (text as NSString).range(of: "네 최애")
        
        attributedString.addAttribute(
            .font,
            value: UIFont.extraBold(size: 24) as Any,
            range: boldTextRange
        )
        $0.font = .light(size: 24)
        $0.attributedText = attributedString
        $0.textColor = .black
    }
    
    let categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 11
        layout.minimumLineSpacing = 16
        layout.itemSize = CategoryCell.size
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = AdBannerHeaderView.size
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsVerticalScrollIndicator = false
        $0.clipsToBounds = true
        $0.register(
            CategoryCell.self,
            forCellWithReuseIdentifier: CategoryCell.registerId
        )
        $0.register(
            AdBannerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AdBannerHeaderView.registerID
        )
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.backgroundButton,
            self.containerView,
            self.topIndicator,
            self.titleLabel,
            self.categoryCollectionView
        ])
    }
    
    override func bindConstraints() {
        self.backgroundButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.containerView.snp.top)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(44)
        }
        
        self.topIndicator.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(16)
            make.centerX.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.topIndicator.snp.bottom).offset(26)
        }
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
        }
    }
}
