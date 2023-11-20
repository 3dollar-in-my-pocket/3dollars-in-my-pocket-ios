import UIKit

import Common
import Model

final class ReportReasonCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width - 40, height: 44)
    }
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderColor = Colors.gray40.color.cgColor
        containerView.layer.borderWidth = 1
        containerView.backgroundColor = Colors.systemWhite.color
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        
        return label
    }()
    
    private let checkImage: UIImageView = {
        let checkImage = UIImageView(image: Icons.check.image.withTintColor(Colors.mainRed.color))
        checkImage.isHidden = true
        return checkImage
    }()
    
    override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            titleLabel,
            checkImage
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.size.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.centerY.equalTo(containerView)
            $0.height.equalTo(20)
        }
        
        checkImage.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.right.equalTo(containerView).offset(-12)
            $0.size.equalTo(20)
        }
    }
    
    func bind(_ reason: ReportReason) {
        titleLabel.text = reason.description
    }
    
    private func setSelected(_ isSelected: Bool) {
        if isSelected {
            containerView.layer.borderColor = Colors.mainRed.color.cgColor
            checkImage.isHidden = false
            titleLabel.textColor = Colors.gray100.color
        } else {
            containerView.layer.borderColor = Colors.gray40.color.cgColor
            checkImage.isHidden = true
            titleLabel.textColor = Colors.gray80.color
        }
    }
}
