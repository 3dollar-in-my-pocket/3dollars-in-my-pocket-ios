import Foundation

struct BossStoreAppearanceDay: Equatable {
    let dayOfTheWeek: DayOfTheWeek
    let locationDescription: String
    let openingHours: Date
    let closingHours: Date
    let isClosedDay: Bool
    
    init(response: BossStoreAppearanceDayResponse) {
        self.dayOfTheWeek = DayOfTheWeek(value: response.dayOfTheWeek)
        self.locationDescription = response.locationDescription
        self.openingHours = response.openingHours.startTime.toDate()
        self.closingHours = response.openingHours.endTime.toDate()
        self.isClosedDay = false
    }
    
    init(dayOfTheWeek: DayOfTheWeek) {
        self.dayOfTheWeek = dayOfTheWeek
        self.locationDescription = ""
        self.openingHours = Date()
        self.closingHours = Date()
        self.isClosedDay = true
    }
}

extension BossStoreAppearanceDay {
    var index: Int {
        switch self.dayOfTheWeek {
        case .monday:
            return 0
            
        case .tuesday:
            return 1
            
        case .wednesday:
            return 2
            
        case .thursday:
            return 3
            
        case .friday:
            return 4
            
        case .saturday:
            return 5
            
        case .sunday:
            return 6
        }
    }
}
