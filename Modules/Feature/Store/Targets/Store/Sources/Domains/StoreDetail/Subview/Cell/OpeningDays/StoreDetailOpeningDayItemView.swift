import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailOpeningDayItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 64
    }

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
        $0.image = Assets.imageDivider.image.withTintColor(Colors.gray30.color)
    }

    override func setup() {
        super.setup()

        addSubViews([
            weekDayLabel,
            timeLabel,
            locationLabel,
            dividerView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        weekDayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }

        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(self.weekDayLabel)
        }

        locationLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.timeLabel)
            $0.top.equalTo(self.timeLabel.snp.bottom).offset(2)
        }

        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(locationLabel.snp.bottom).offset(12)
            $0.height.equalTo(1)
        }

        snp.makeConstraints {
            $0.height.equalTo(Layout.height).priority(.high)
        }
    }
    
    func bind(
        openingDay: StoreOpeningDaysSectionResponse.StoreOpeningDaySectionResponse,
        isLast: Bool
    ) {
        weekDayLabel.setSDText(openingDay.dayOfTheWeek)
        timeLabel.setSDText(openingDay.opeingTime)
        if let placeDescription = openingDay.placeDescription {
            locationLabel.setSDText(placeDescription)
        }
        dividerView.isHidden = isLast
    }
}
