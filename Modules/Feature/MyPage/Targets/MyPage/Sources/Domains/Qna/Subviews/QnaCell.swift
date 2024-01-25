import UIKit

import Common
import DesignSystem

final class QnaCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 48)
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.semiBold.font(size: 14)
        label.textAlignment = .left
        
        return label
    }()
    
    private let rightArrowImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = Icons.arrowRight.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.systemWhite.color
        return imageView
    }()
    
    override func setup() {
        contentView.addSubViews([
            titleLabel,
            rightArrowImage
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(rightArrowImage.snp.leading).offset(-12)
        }
        
        rightArrowImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(12)
        }
    }
    
    func bind(cellType: QnaCellType) {
        titleLabel.text = cellType.title
    }
}
