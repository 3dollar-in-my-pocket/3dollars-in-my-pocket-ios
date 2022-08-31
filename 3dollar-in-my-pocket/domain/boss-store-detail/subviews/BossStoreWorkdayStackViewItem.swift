import UIKit

import Base

final class BossStoreWorkdayStackViewItem: Base.BaseView {
    static let height: CGFloat = 66
    
    private let weekDayLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .black
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = R.color.gray70()
        $0.textAlignment = .right
    }
    
    private let locationLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = R.color.gray70()
        $0.textAlignment = .right
    }
    
    private let dividerView = UIImageView().then {
        $0.image = R.image.img_divider()
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
        if appearanceDay.dayOfTheWeek == .saturday || appearanceDay.dayOfTheWeek == .sunday {
            self.weekDayLabel.textColor = R.color.red()
        } else {
            self.weekDayLabel.textColor = R.color.gray70()
        }
        if appearanceDay.isClosedDay {
            self.timeLabel.text = R.string.localization.boss_store_closed_day()
            self.timeLabel.textColor = .red
            self.locationLabel.text = "-"
        } else {
            let startTime = Base.DateUtils.toString(
                date: appearanceDay.openingHours,
                format: "HH:mm"
            )
            let endTime = Base.DateUtils.toString(
                date: appearanceDay.closingHours,
                format: "HH:mm"
            )
            
            self.timeLabel.text = "\(startTime) - \(endTime)"
            self.timeLabel.textColor = R.color.gray70()
            self.locationLabel.text = appearanceDay.locationDescription
        }
    }
}
