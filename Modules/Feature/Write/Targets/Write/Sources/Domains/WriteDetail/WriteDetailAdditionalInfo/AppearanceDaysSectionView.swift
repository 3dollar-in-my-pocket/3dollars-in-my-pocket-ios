import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit
import CombineCocoa

extension AppearanceDaysSectionView {
    private class DayButton: UIButton {
        let appearanceDay: AppearanceDay
        private let titleString: String
        
        override var isSelected: Bool {
            didSet {
                updateSelectState(isSelected)
            }
        }
        
        init(title: String, appearanceDay: AppearanceDay) {
            self.titleString = title
            self.appearanceDay = appearanceDay
            super.init(frame: .zero)
            
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            setTitle(titleString, for: .normal)
            titleLabel?.font = Fonts.semiBold.font(size: 14)
            layer.cornerRadius = 18
            layer.masksToBounds = true
            layer.borderWidth = 1
            backgroundColor = .clear
            
            snp.makeConstraints {
                $0.size.equalTo(36)
            }
            
            updateSelectState(false)
        }
        
        private func updateSelectState(_ isSelected: Bool) {
            if isSelected {
                setTitleColor(Colors.mainPink.color, for: .normal)
                layer.borderColor = Colors.mainPink.color.cgColor
            } else {
                setTitleColor(Colors.gray40.color, for: .normal)
                layer.borderColor = Colors.gray30.color.cgColor
            }
        }
    }
}

final class AppearanceDaysSectionView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "출몰 요일"
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let requiredLabel: UILabel = {
        let label = UILabel()
        label.text = "*다중선택 가능"
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.mainPink.color
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let mondayButton = DayButton(title: "월", appearanceDay: .monday)
    private let tuesdayButton = DayButton(title: "화", appearanceDay: .tuesday)
    private let wednesdayButton = DayButton(title: "수", appearanceDay: .wednesday)
    private let thursdayButton = DayButton(title: "목", appearanceDay: .thursday)
    private let fridayButton = DayButton(title: "금", appearanceDay: .friday)
    private let saturdayButton = DayButton(title: "토", appearanceDay: .saturday)
    private let sundayButton = DayButton(title: "일", appearanceDay: .sunday)
    
    private lazy var dayButtons: [DayButton] = [
        mondayButton, tuesdayButton, wednesdayButton, thursdayButton,
        fridayButton, saturdayButton, sundayButton
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private var selectedDays = Set<AppearanceDay>()
    
    var selectedDayChanged = PassthroughSubject<AppearanceDay, Never>()
    
    private let dayMapping: [Int: AppearanceDay] = [
        0: .monday,
        1: .tuesday,
        2: .wednesday,
        3: .thursday,
        4: .friday,
        5: .saturday,
        6: .sunday
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubViews([
            titleLabel,
            requiredLabel,
            buttonStackView
        ])
        
        dayButtons.forEach { button in
            buttonStackView.addArrangedSubview(button)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        requiredLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(36)
        }
        
    }
    
    private func bind() {
        mondayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.mondayButton.isSelected.toggle()
                self?.toggleDay(0)
            }
            .store(in: &cancellables)
        
        tuesdayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.tuesdayButton.isSelected.toggle()
                self?.toggleDay(1)
            }
            .store(in: &cancellables)
        
        wednesdayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.wednesdayButton.isSelected.toggle()
                self?.toggleDay(2)
            }
            .store(in: &cancellables)
        
        thursdayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.thursdayButton.isSelected.toggle()
                self?.toggleDay(3)
            }
            .store(in: &cancellables)
        
        fridayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.fridayButton.isSelected.toggle()
                self?.toggleDay(4)
            }
            .store(in: &cancellables)
        
        saturdayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.saturdayButton.isSelected.toggle()
                self?.toggleDay(5)
            }
            .store(in: &cancellables)
        
        sundayButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.sundayButton.isSelected.toggle()
                self?.toggleDay(6)
            }
            .store(in: &cancellables)
    }
    
    private func toggleDay(_ dayIndex: Int) {
        guard let day = dayMapping[dayIndex] else { return }
        
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
        selectedDayChanged.send(day)
    }
    
    func selectDays(_ days: [AppearanceDay]) {
        selectedDays = Set(days)
        
        dayButtons.forEach { button in
            button.isSelected = selectedDays.contains(button.appearanceDay)
        }
    }
}
