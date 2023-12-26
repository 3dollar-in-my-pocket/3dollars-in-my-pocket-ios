import UIKit

import Common
import DesignSystem
import Model

final class BossStoreWorkdayCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 492
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = Strings.BossStoreDetail.Workday.title
    }

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.stackView.subviews.forEach { $0.removeFromSuperview() }
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            containerView
        ])

        containerView.addSubview(stackView)
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview()
        }
    }

    func bind(appearanceDays: [BossStoreAppearanceDay]) {
        var resultAppearanceDays = [
            BossStoreAppearanceDay(dayOfTheWeek: .monday),
            BossStoreAppearanceDay(dayOfTheWeek: .tuesday),
            BossStoreAppearanceDay(dayOfTheWeek: .wednesday),
            BossStoreAppearanceDay(dayOfTheWeek: .thursday),
            BossStoreAppearanceDay(dayOfTheWeek: .friday),
            BossStoreAppearanceDay(dayOfTheWeek: .saturday),
            BossStoreAppearanceDay(dayOfTheWeek: .sunday)
        ]

        appearanceDays.forEach { resultAppearanceDays[$0.index] = $0 }

        for appearanceDay in resultAppearanceDays {
            let stackViewItem = generateStackViewItem(appearanceDay: appearanceDay)

            stackView.addArrangedSubview(stackViewItem)
        }
    }

    func generateStackViewItem(appearanceDay: BossStoreAppearanceDay) -> BossStoreWorkdayStackViewItem {
        let stackViewItem = BossStoreWorkdayStackViewItem()
        stackViewItem.bind(appearanceDay: appearanceDay)
        return stackViewItem
    }
}
