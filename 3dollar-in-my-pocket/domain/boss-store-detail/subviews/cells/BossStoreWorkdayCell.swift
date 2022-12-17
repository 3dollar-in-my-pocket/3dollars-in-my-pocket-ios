import UIKit

final class BossStoreWorkdayCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreWorkdayCell.self)"
    static let height: CGFloat = 466
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .white
        $0.layoutMargins = .init(top: 4, left: 0, bottom: 0, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stackView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        self.addSubViews([
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
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
            let stackViewItem = self.generateStackViewItem(appearanceDay: appearanceDay)
            
            self.stackView.addArrangedSubview(stackViewItem)
        }
    }
    
    func generateStackViewItem(
        appearanceDay: BossStoreAppearanceDay
    ) -> BossStoreWorkdayStackViewItem {
        let stackViewItem = BossStoreWorkdayStackViewItem()
        
        stackViewItem.bind(appearanceDay: appearanceDay)
        return stackViewItem
    }
}
