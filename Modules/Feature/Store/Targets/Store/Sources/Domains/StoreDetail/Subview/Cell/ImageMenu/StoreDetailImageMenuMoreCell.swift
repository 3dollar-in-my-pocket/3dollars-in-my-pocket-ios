import UIKit
import Common
import DesignSystem
import Model

final class StoreDetailImageMenuMoreCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 50
    }

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        return label
    }()

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
        titleLabel.text = Strings.BossStoreDetail.Menu.menuMoreFormat(count)
    }
}
