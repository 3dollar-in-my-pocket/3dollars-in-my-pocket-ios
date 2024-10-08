import UIKit

import Common
import DesignSystem
import Model

final class CategoryAdvertisementCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(
            width: (UIScreen.main.bounds.width - 48 - 36)/4,
            height: (UIScreen.main.bounds.width - 48 - 36)/4 + 2
        )
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DesignSystemAsset.Colors.gray70.color
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        backgroundColor = .clear
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(56)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(advertisement: AdvertisementResponse) {
        if let image = advertisement.image {
            imageView.setImage(urlString: image.url)
        }
        
        if let width = advertisement.image?.width,
            let height = advertisement.image?.height {
            imageView.snp.updateConstraints {
                $0.width.equalTo(width)
                $0.height.equalTo(height)
            }
        }
        
        titleLabel.text = advertisement.title?.content
        if let textColor = advertisement.title?.fontColor {
            titleLabel.textColor = UIColor(hex: textColor)
        }
    }
}
