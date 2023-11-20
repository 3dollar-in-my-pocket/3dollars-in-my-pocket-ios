import UIKit

import Model

final class StoreDetailInfoAppearanceDayStackView: UIStackView {
    private let mondayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.monday)
    private let tuesdayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.tuesday)
    private let wednesdayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.wednesday)
    private let thursdayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.thursday)
    private let fridayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.friday)
    private let saturdayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.saturday)
    private let sundayItem = StoreDetailInfoAppearanceDayStackItemView(value: Strings.StoreDetail.Info.sunday)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ appearanceDays: [AppearanceDay]) {
        clearAppearanceDays()
        for appearanceDay in appearanceDays {
            switch appearanceDay {
            case .monday:
                mondayItem.setSelected(true)
                
            case .tuesday:
                tuesdayItem.setSelected(true)
                
            case .wednesday:
                wednesdayItem.setSelected(true)
                
            case .thursday:
                thursdayItem.setSelected(true)
                
            case .friday:
                fridayItem.setSelected(true)
                
            case .saturday:
                saturdayItem.setSelected(true)
                
            case .sunday:
                sundayItem.setSelected(true)
                
            case .unknown:
                continue
            }
        }
    }
    
    private func setup() {
        spacing = 2
        axis = .horizontal
        addArrangedSubview(mondayItem)
        addArrangedSubview(tuesdayItem)
        addArrangedSubview(wednesdayItem)
        addArrangedSubview(thursdayItem)
        addArrangedSubview(fridayItem)
        addArrangedSubview(saturdayItem)
        addArrangedSubview(sundayItem)
    }
    
    private func clearAppearanceDays() {
        mondayItem.setSelected(false)
        tuesdayItem.setSelected(false)
        wednesdayItem.setSelected(false)
        thursdayItem.setSelected(false)
        fridayItem.setSelected(false)
        saturdayItem.setSelected(false)
        sundayItem.setSelected(false)
    }
}
