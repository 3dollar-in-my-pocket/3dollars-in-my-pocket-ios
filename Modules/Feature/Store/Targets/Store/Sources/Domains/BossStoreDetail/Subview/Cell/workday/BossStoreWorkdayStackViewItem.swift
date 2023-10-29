import UIKit

import Common
import DesignSystem
import Model

final class BossStoreWorkdayStackViewItem: BaseView {
    static let height: CGFloat = 66

    private let weekDayLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray100.color
    }

    private let timeLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray70.color
        $0.textAlignment = .right
    }

    private let locationLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.textAlignment = .right
    }

    private let dividerView = UIImageView().then {
        $0.image = UIImage(named: "img_divider")?.withTintColor(Colors.gray30.color)
    }

    override func setup() {
        self.addSubViews([
            self.weekDayLabel,
            self.timeLabel,
            self.locationLabel,
            self.dividerView
        ])
    }

    override func bindConstraints() {
        self.weekDayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
        }

        self.timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(self.weekDayLabel)
        }

        self.locationLabel.snp.makeConstraints { make in
            make.right.equalTo(self.timeLabel)
            make.top.equalTo(self.timeLabel.snp.bottom).offset(2)
        }

        self.dividerView.snp.makeConstraints { make in
            make.left.equalTo(self.timeLabel)
            make.right.equalTo(self.locationLabel)
            make.top.equalTo(locationLabel.snp.bottom).offset(12)
            make.height.equalTo(1)
        }

        self.snp.makeConstraints { make in
            make.height.equalTo(Self.height).priority(.high)
        }
    }

    func bind(appearanceDay: BossStoreAppearanceDay) {
        self.weekDayLabel.text = appearanceDay.dayOfTheWeek.fullText
        self.dividerView.isHidden = appearanceDay.dayOfTheWeek == .sunday
        if appearanceDay.isClosedDay {
            self.timeLabel.text = "휴무"
            self.timeLabel.textColor = Colors.gray50.color
            self.locationLabel.text = "-"
        } else {
            let startTime = DateUtils.toString(
                date: appearanceDay.openingHours,
                format: "HH:mm"
            )
            let endTime = DateUtils.toString(
                date: appearanceDay.closingHours,
                format: "HH:mm"
            )

            self.timeLabel.text = "\(startTime) - \(endTime)"
            self.timeLabel.textColor = Colors.gray70.color
            self.locationLabel.text = appearanceDay.locationDescription
        }
    }
}
