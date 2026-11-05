import UIKit
import Combine

import Common
import DesignSystem

final class ReviewPhotoListCell: BaseCollectionViewCell {
    private let imageView = UIImageView()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deletePhoto.image, for: .normal)
        
        return button
    }()

    
    override func setup() {
        super.setup()

        clipsToBounds = true
        layer.cornerRadius = 12
        backgroundColor = Colors.gray10.color
        imageView.contentMode = .scaleAspectFill

        contentView.addSubview(imageView)
        contentView.addSubview(removeButton)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(28)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.clear()
    }
    
    func bind(imageUrl: String?, canEdit: Bool) {
        imageView.setImage(urlString: imageUrl)
        removeButton.isHidden = canEdit.isNot
    }
}

final class ReviewPhotoListHeaderView: BaseCollectionViewReusableView {
    let didTapEvent = PassthroughSubject<Void, Never>()
    
    private let plusBackgroundView: UIView = {
        let plusBackgroundView = UIView()
        plusBackgroundView.backgroundColor = Colors.gray60.color
        plusBackgroundView.clipsToBounds = true
        plusBackgroundView.layer.cornerRadius = 11
        return plusBackgroundView
    }()
    
    private let plusImageView: UIImageView = {
        let plusImageView = UIImageView()
        plusImageView.image = Icons.plus.image.withTintColor(Colors.systemWhite.color)
        return plusImageView
    }()

    private let countLabel = UILabel()
    
    override func setup() {
        super.setup()
        
        addSubViews([
            plusBackgroundView,
            countLabel
        ])
        
        plusBackgroundView.addSubview(plusImageView)
        
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = Colors.gray20.color.cgColor
        backgroundColor = Colors.gray10.color
        
        plusBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(13)
            $0.size.equalTo(22)
            $0.centerX.equalToSuperview()
        }
        
        plusImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(16)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(plusBackgroundView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    func bind(totalCount: Int, maxCount: Int) {
        let text = NSMutableAttributedString(
            string: "\(totalCount)",
            attributes: [.font: Fonts.bold.font(size: 16), .foregroundColor: Colors.mainPink.color]
        )
        text.append(NSAttributedString(
            string: "/\(maxCount)",
            attributes: [.font: Fonts.regular.font(size: 16), .foregroundColor: Colors.gray40.color]
        ))
        countLabel.attributedText = text
    }

    @objc private func didTap() {
        didTapEvent.send()
    }
}
