import UIKit

final class CategoryFilterView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    }
    
    private let topIndicator = UIImageView().then {
        $0.image = UIImage(named: "img_top_indicator")
    }
    
    private let titleLabel = UILabel().then {
        let text = "category_title".localized
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
        layout.itemSize = CategoryFilterCell.size
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CategoryFilterHeaderView.size
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsVerticalScrollIndicator = false
        $0.clipsToBounds = true
        $0.register(
            CategoryFilterCell.self,
            forCellWithReuseIdentifier: CategoryFilterCell.registerId
        )
        $0.register(
            CategoryFilterHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryFilterHeaderView.registerID
        )
    }
    
    private let gradientView = UIView().then {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(1).cgColor
        ]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 80
        )
        $0.layer.addSublayer(gradient)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.backgroundButton,
            self.containerView,
            self.topIndicator,
            self.titleLabel,
            self.categoryCollectionView,
            self.gradientView
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
        
        self.gradientView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
    }
}
