import UIKit

import Common
import DesignSystem

final class HomeListEmptyCell: BaseCollectionViewCell {
    
    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 220)
    }
    
    private let emptyImageView = UIImageView(image: Assets.imageEmptyList.image)
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray70.color
        label.text = Strings.HomeList.Empty.title
        
        return label
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        label.text = Strings.HomeList.Empty.description
        
        return label
    }()
    
    override func setup() {
        contentView.addSubViews([
            emptyImageView,
            emptyTitleLabel,
            emptyDescriptionLabel
        ])
    }
    
    override func bindConstraints() {
        emptyImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(112)
        }
        
        emptyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        emptyDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
}

