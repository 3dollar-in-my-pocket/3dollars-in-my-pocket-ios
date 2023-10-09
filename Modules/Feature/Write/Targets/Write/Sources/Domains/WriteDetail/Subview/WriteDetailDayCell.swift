import UIKit
import Combine

import Common
import DesignSystem
import Model

final class WriteDetailDayCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 64)
    }
    
    var tapPublisher: PassthroughSubject<AppearanceDay, Never> {
        return dayStackView.tapPublisher
    }
    
    private let dayStackView = DayStackView()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        contentView.addSubview(dayStackView)
    }
    
    override func bindConstraints() {
        dayStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-28)
        }
    }
}

extension WriteDetailDayCell {
    final class DayStackView: UIStackView {
        let tapPublisher = PassthroughSubject<AppearanceDay, Never>()
        
        var cancellables = Set<AnyCancellable>()
        
        private let dayButtons: [DayButton] = [
            DayButton(.monday),
            DayButton(.tuesday),
            DayButton(.wednesday),
            DayButton(.thursday),
            DayButton(.friday),
            DayButton(.saturday),
            DayButton(.sunday)
        ]
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setup()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            alignment = .center
            axis = .horizontal
            distribution = .equalSpacing
            spacing = 12
            
            dayButtons.forEach { button in
                addArrangedSubview(button)
                button.controlPublisher(for: .touchUpInside)
                    .withUnretained(self)
                    .sink { owner, _ in
                        owner.tapPublisher.send(button.appearanceDay)
                        button.isSelected.toggle()
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    final class DayButton: UIButton {
        enum Layout {
            static let size = CGSize(width: 36, height: 36)
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    layer.borderColor = Colors.mainPink.color.cgColor
                } else {
                    layer.borderColor = Colors.gray30.color.cgColor
                }
                
            }
        }
        
        let appearanceDay: AppearanceDay
        
        init(_ appearanceDay: AppearanceDay) {
            self.appearanceDay = appearanceDay
            super.init(frame: .zero)
            
            setup()
            bindConstratins()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            layer.cornerRadius = 18
            layer.masksToBounds = true
            layer.borderWidth = 1
            layer.borderColor = Colors.gray30.color.cgColor
            setTitle(appearanceDay.shortText, for: .normal)
            setTitleColor(Colors.gray40.color, for: .normal)
            setTitleColor(Colors.mainPink.color, for: .selected)
            titleLabel?.font = Fonts.semiBold.font(size: 14)
        }
        
        private func bindConstratins() {
            snp.makeConstraints {
                $0.size.equalTo(Layout.size)
            }
        }
    }
}

extension AppearanceDay {
    var shortText: String {
        switch self {
        case .monday:
            return "월"
            
        case .tuesday:
            return "화"
            
        case .wednesday:
            return "수"
            
        case .thursday:
            return "목"
            
        case .friday:
            return "금"
            
        case .saturday:
            return "토"
            
        case .sunday:
            return "일"
            
        default:
            return ""
        }
    }
}
