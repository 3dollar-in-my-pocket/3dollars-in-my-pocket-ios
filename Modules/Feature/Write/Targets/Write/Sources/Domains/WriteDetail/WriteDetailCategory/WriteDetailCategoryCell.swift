import UIKit

import Common
import DesignSystem
import Model

final class WriteDetailCategoryCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateSize(category: StoreFoodCategoryResponse, isSmall: Bool = false) -> CGSize {
            let imageWidth: CGFloat = 24
            let nameWidth = category.name.size(withAttributes: [.font: Fonts.semiBold.font(size: 14)]).width
            let padding: CGFloat = isSmall ? 20 : 29
            
            return CGSize(width: imageWidth + nameWidth + padding, height: isSmall ? 32 : 40)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.masksToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            updateSelectedState()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = self.frame.height / 2
    }
    
    override func setup() {
        contentView.addSubview(containerView)
        containerView.addSubViews([
            imageView,
            nameLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(4)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bind(category: StoreFoodCategoryResponse, selected: Bool, isSmall: Bool = false) {
        nameLabel.text = category.name
        imageView.setImage(urlString: category.imageUrl)
        isSelected = selected
        
        if isSmall {
            imageView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(8)
            }
            
            nameLabel.snp.updateConstraints {
                $0.trailing.lessThanOrEqualToSuperview().offset(-8)
            }
        }
    }
    
    private func updateSelectedState() {
        containerView.backgroundColor = isSelected ? Colors.pink200.color : Colors.gray10.color
        nameLabel.textColor = isSelected ? Colors.mainPink.color : Colors.gray100.color
    }
} 
