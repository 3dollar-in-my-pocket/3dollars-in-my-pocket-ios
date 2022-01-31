import UIKit

final class CategoryView: BaseView {
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
        layout.itemSize = CategoryCell.size
        layout.scrollDirection = .vertical
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.showsVerticalScrollIndicator = false
        $0.clipsToBounds = false
        $0.register(
            CategoryCell.self,
            forCellWithReuseIdentifier: CategoryCell.registerId
        )
    }
    
    
    override func setup() {
        self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        self.addSubViews([
            self.titleLabel,
            self.categoryCollectionView
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(35)
        }
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(32)
        }
    }
}
