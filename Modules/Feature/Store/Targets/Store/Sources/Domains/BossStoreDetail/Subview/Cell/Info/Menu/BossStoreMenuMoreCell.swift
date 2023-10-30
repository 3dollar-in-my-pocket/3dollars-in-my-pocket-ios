import UIKit
import Common
import DesignSystem
import Model

final class BossStoreMenuMoreCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 50
    }

    private let lineView = UIView().then {
        $0.backgroundColor = Colors.gray20.color
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }

    override func setup() {
        super.setup()

        backgroundColor = .clear

        contentView.addSubViews([
            lineView,
            titleLabel
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        lineView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }

    func bind(count: Int) {
        titleLabel.text = "메뉴 \(count)개 더보기"
    }
}
