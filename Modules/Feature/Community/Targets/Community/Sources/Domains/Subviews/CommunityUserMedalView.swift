import UIKit
import Combine

import DesignSystem
import Common

final class CommunityUserMedalView: BaseView {

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 4
        // 칭호 뱃지 디자인 지정 색, DesignSystem 토큰 없음
        // swiftlint:disable:next no_uicolor_literal
        containerView.backgroundColor = UIColor(hex: "#FFA1AA")?.withAlphaComponent(0.1)
        return containerView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 10)
        titleLabel.textColor = Colors.mainPink.color
        return titleLabel
    }()

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
        // 칭호 뱃지 디자인 지정 색, DesignSystem 토큰 없음
        // swiftlint:disable:next no_uicolor_literal
        containerView.backgroundColor = color ?? UIColor(hex: "#FFA1AA")?.withAlphaComponent(0.1)
    }
}
