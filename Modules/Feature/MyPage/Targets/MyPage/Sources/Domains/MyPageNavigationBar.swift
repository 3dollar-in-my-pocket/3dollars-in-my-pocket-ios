import UIKit

import Common
import DesignSystem
import SnapKit
import Then

final class MyPageNavigationBar: BaseView {

    enum Layout {
        static let height: CGFloat = 56
    }

    let backButton = UIButton().then {
        $0.setImage(
            Icons.arrowLeft.image
                .resizeImage(scaledTo: 24)
                .withTintColor(Colors.systemWhite.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    }

    let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = Colors.systemWhite.color
    }

    let rightStackView = UIStackView().then {
        $0.axis = .horizontal
    }

    init(title: String? = nil, rightButtons: [UIButton] = []) {
        super.init(frame: .zero)

        titleLabel.text = title
        rightButtons.forEach {
            rightStackView.addArrangedSubview($0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        backgroundColor = Colors.gray100.color

        addSubViews([
            backButton,
            titleLabel,
            rightStackView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        rightStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
