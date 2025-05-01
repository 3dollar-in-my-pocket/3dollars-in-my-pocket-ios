import UIKit

import Common
import DesignSystem
import Model

final class FeedCellContentWithImagesBodyView: BaseView {
    enum Layout {
        static func calculateHeight(body: ContentWithImagesFeedBodyResponse) -> CGFloat {
            let width = UIUtils.windowBounds.width - 56
            let contentHeight = body.content.text.height(font: Fonts.regular.font(size: 14), width: width)
            
            return contentHeight + 168
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register([
            ImageCell.self,
            UICollectionViewCell.self
        ])
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        return layout
    }
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray95.color
        return label
    }()
    
    private var images: [ImageResponse] = []
    
    override func setup() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        backgroundColor = Colors.gray0.color
        addSubViews([
            collectionView,
            contentLabel
        ])
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(124)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(collectionView.snp.bottom).offset(12)
        }
    }
    
    func bind(body: ContentWithImagesFeedBodyResponse) {
        backgroundColor = UIColor(hex: body.style.backgroundColor)
        contentLabel.setUiText(body.content)
        
        images = body.images
        collectionView.reloadData()
    }
}

extension FeedCellContentWithImagesBodyView: UICollectionViewDataSource {
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

extension FeedCellContentWithImagesBodyView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let image = images[safe: indexPath.item],
              let width = image.width,
              let height = image.height else { return .zero }
        
        let ratio = CGFloat(width) / CGFloat(height)
        let cellHeight = ImageCell.Layout.height
        return CGSize(width: cellHeight * ratio, height: ImageCell.Layout.height)
    }
}
    

extension FeedCellContentWithImagesBodyView {
    private final class ImageCell: BaseCollectionViewCell {
        enum Layout {
            static let height: CGFloat = 124
        }
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8
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
