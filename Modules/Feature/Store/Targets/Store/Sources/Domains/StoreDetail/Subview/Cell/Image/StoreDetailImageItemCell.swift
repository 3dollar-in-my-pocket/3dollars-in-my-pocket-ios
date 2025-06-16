import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailImageItemCell: BaseCollectionViewCell {
    enum Layout {
        static let width = (UIUtils.windowBounds.width - 40 - 24) / 4
        static let size = CGSize(width: width, height: width)
        static let space: CGFloat = 8
    }
    
    private let photoView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemBlack.color.withAlphaComponent(0.5)
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let countValueLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.mainPink.color
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray0.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    override func setup() {
        contentView.addSubViews([
            photoView,
            dimmedView,
            countValueLabel,
            countLabel
        ])
    }
    
    override func bindConstraints() {
        photoView.snp.makeConstraints {
            $0.edges.equalToSuperview().priority(.high)
            $0.size.equalTo(Layout.size)
        }
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalTo(photoView)
        }
        
        countValueLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(photoView.snp.centerY)
            $0.height.equalTo(18)
        }
        
        countLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoView.snp.centerY)
            $0.height.equalTo(18)
        }
    }
    
    func bind(sdImage: SDImage) {
        photoView.setImage(urlString: sdImage.url)
        dimmedView.isHidden = true
        countLabel.isHidden = true
        countValueLabel.isHidden = true
    }
    
    func bind(more: StoreImagesSectionResponse.StoreImageMoreSectionResponse) {
        dimmedView.isHidden = false
        countLabel.isHidden = false
        countValueLabel.isHidden = false
        countLabel.setSDText(more.title)
        if let subTitle = more.subTitle {
            countValueLabel.setSDText(subTitle)
        }
    }
}
