import RxDataSources

struct MyMedalSectionModel: Equatable {
    var items: [MyMedalSectionType]
}

extension MyMedalSectionModel: SectionModelType {
    enum MyMedalSectionType: Equatable {
        case currentMedal(Medal)
        case medal(Medal)
    }
    
    init(original: MyMedalSectionModel, items: [MyMedalSectionType]) {
        self = original
        self.items = items
    }
    
    init(currentMedal: Medal) {
        self.items = [.currentMedal(currentMedal)]
    }
    
    init(medals: [Medal]) {
        self.items = medals.map { .medal($0) }
    }
}
