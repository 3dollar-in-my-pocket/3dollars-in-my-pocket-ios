import UIKit

import Common
import Model
import DesignSystem

final class FeedCellContentWithTitleAndImagesBodyView: BaseView {
    enum Layout {
        static func calculateHeight(body: ContentWithTitleAndImagesFeedBodyResponse) -> CGFloat {
            let width = UIUtils.windowBounds.width - 56
            let contentHeight = body.content.text.height(font: Fonts.regular.font(size: 14), width: width)
            
            return contentHeight + 116
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        
        return label
    }()
    
    private let starBadgeView = StarBadgeView()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register([
            ImageCell.self,
            UICollectionViewCell.self
        ])
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()
    
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.numberOfLines = 5
        return label
    }()
    
    private var images: [ImageResponse] = []
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubViews([
            titleLabel,
            starBadgeView,
            collectionView,
            contentLabel
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(13)
            $0.trailing.lessThanOrEqualTo(starBadgeView.snp.leading).offset(-12)
        }
        
        starBadgeView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(StarBadgeView.Layout.size)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(starBadgeView.snp.bottom).offset(8)
            $0.height.equalTo(56)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalTo(collectionView.snp.bottom).offset(8)
        }
    }
    
    func bind(body: ContentWithTitleAndImagesFeedBodyResponse) {
        titleLabel.setSDText(body.title)
        
        if let rating = body.additionalInfos?.rating?.starRating {
            starBadgeView.bind(Int(rating))
        }
        
        contentLabel.setSDText(body.content)
        backgroundColor = UIColor(hex: body.style.backgroundColor)
        
        images = body.images
        collectionView.reloadData()
    }
    
    private func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = ImageCell.Layout.size
        return layout
    }
}

extension FeedCellContentWithTitleAndImagesBodyView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let image = images[safe: indexPath.item] else {
            return collectionView.dequeueReusableCell(indexPath: indexPath)
        }
        
        let cell: ImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(image: image)
        return cell
    }
}
    

extension FeedCellContentWithTitleAndImagesBodyView {
    private final class ImageCell: BaseCollectionViewCell {
        enum Layout {
            static let size = CGSize(width: 56, height: 56)
        }
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            return imageView
        }()
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            imageView.image = nil
        }
        
        override func setup() {
            contentView.addSubview(imageView)
            
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        func bind(image: ImageResponse) {
            imageView.setImage(urlString: image.imageUrl)
        }
    }
}

