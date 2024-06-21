import UIKit
import Common
import DesignSystem
import Model

final class BossStorePostCell: BaseCollectionViewCell {
    enum Layout {
        static let sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = "가게 소식"
    }
    
    private let moreButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 16
    }
    
    private let categoryImageView = UIImageView()
    
    private let storeNameLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 14)
        $0.textColor = Colors.gray100.color
    }
    
    private let updatedAtLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 12)
        $0.textColor = Colors.gray40.color
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.dataSource = self
        $0.delegate = self
        $0.decelerationRate = .fast
        $0.register([BossStorePostImageCell.self])
    }
    
    private let contentLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 0
    }
    
    override func setup() {
        backgroundColor = .clear
        
        contentView.addSubViews([
            titleLabel,
            moreButton,
            containerView
        ])
        
        containerView.addSubViews([
            categoryImageView,
            storeNameLabel,
            updatedAtLabel,
            collectionView,
            contentLabel
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        categoryImageView.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.leading.equalToSuperview().inset(16)
        }
        
        storeNameLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            $0.top.equalToSuperview().inset(17)
            $0.height.equalTo(20)
        }
        
        updatedAtLabel.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom)
            $0.leading.equalTo(storeNameLabel)
            $0.height.equalTo(18)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(categoryImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(208)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 208, height: 208)
        layout.scrollDirection = .horizontal
        layout.sectionInset = Layout.sectionInset
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        return layout
    }
    
    func bind(_ viewModel: BossStorePostCellViewModel) {
        moreButton.setTitle("소식 더보기", for: .normal)
        categoryImageView.backgroundColor = .gray
        storeNameLabel.text = "삼식이네 붕어빵"
        updatedAtLabel.text = "3시간 전"
        contentLabel.text = "content"
    }
}

extension BossStorePostCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BossStorePostImageCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        return cell
    }
}

extension BossStorePostCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let offset = collectionView.getNearByItemScrollOffset(velocity: velocity, targetContentOffset: targetContentOffset, sectionInsets: Layout.sectionInset) {
            targetContentOffset.pointee = offset
        }
    }
}

// MARK: - Image Cell
private final class BossStorePostImageCell: BaseCollectionViewCell {
    enum Layout {
        static let sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = Colors.gray70.color
        $0.layer.cornerRadius = 16
    }
    
    override func setup() {
        contentView.addSubview(imageView)
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ viewModel: BossStorePostCellViewModel) {
        
    }
}
