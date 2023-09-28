import UIKit
import Combine

import DesignSystem
import Then
import Common

final class CommunityUserMedalView: BaseView {

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 4
        $0.backgroundColor = UIColor(hex: "#FFA1AA")?.withAlphaComponent(0.1)
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 10)
        $0.textColor = Colors.mainPink.color
    }

    override func setup() {
        super.setup()

        addSubViews([containerView])
        containerView.addSubViews([imageView, titleLabel])

        backgroundColor = .clear
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.top.bottom.leading.equalToSuperview().inset(2)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().inset(4)
        }
    }

    func bind(imageUrl: String?, title: String?) {
        imageView.setImage(urlString: imageUrl)
        titleLabel.text = title
    }

    func setBackgroundColor(_ color: UIColor?) {
        containerView.backgroundColor = color ?? UIColor(hex: "#FFA1AA")?.withAlphaComponent(0.1)
    }
}
