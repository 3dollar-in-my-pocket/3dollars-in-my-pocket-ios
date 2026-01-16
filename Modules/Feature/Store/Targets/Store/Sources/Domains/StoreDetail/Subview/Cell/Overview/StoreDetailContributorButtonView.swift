import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StoreDetailContributorButtonView: UIButton {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 14)
        label.textColor = Colors.gray70.color
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 14)
        label.textColor = Colors.gray60.color
        label.numberOfLines = 1
        return label
    }()

    private let arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.arrowRight.image.resizeImage(scaledTo: 20).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.gray40.color
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(stackView)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(arrowIcon, previousSpace: 4)
    }

    private func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(200)
        }

        arrowIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
    }

    func bind(nickname: String, contributorCount: Int?) {
        guard let contributorCount else {
            isHidden = true
            return
        }

        isHidden = false
        nicknameLabel.text = nickname
        
        if contributorCount > 0 {
            messageLabel.text = Strings.StoreDetail.Overview.Contributor.format(contributorCount)
        } else {
            messageLabel.text = Strings.StoreDetail.Overview.Contributor.creator
        }
    }
}
