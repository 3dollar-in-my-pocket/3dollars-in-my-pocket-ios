import UIKit
import Combine

import Common
import DesignSystem
import Then

final class ReviewPhotoListCell: BaseCollectionViewCell {
    private let imageView = UIImageView()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deleteX.image.withTintColor(Colors.mainRed.color), for: .normal)
        
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
            $0.top.trailing.equalToSuperview().inset(4)
            $0.size.equalTo(20)
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
    
    private let plusBackgroundView = UIView().then {
        $0.backgroundColor = Colors.gray100.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 14
    }
    
    private let plusImageView = UIImageView().then {
        $0.image = Icons.plus.image.withTintColor(Colors.mainPink.color)
    }
    private let countLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray95.color
    }
    
    override func setup() {
        super.setup()
        
        addSubViews([
            plusBackgroundView,
            countLabel
        ])
        
        plusBackgroundView.addSubview(plusImageView)
        
        clipsToBounds = true
        layer.cornerRadius = 10
        backgroundColor = Colors.gray10.color
        
        plusBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(11)
            $0.size.equalTo(28)
            $0.centerX.equalToSuperview()
        }
        
        plusImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(plusBackgroundView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func bind(totalCount: Int) {
        countLabel.text = "\(totalCount)/10"
    }

    @objc private func didTap() {
        didTapEvent.send()
    }
}
