import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit
import CombineCocoa

extension OpeningHoursSectionView {
    private class TimeField: UIView {
        private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = Colors.gray10.color
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
            return view
        }()
        
        let textField: UITextField = {
            let textField = UITextField()
            textField.textAlignment = .left
            textField.font = Fonts.regular.font(size: 14)
            textField.textColor = Colors.gray100.color
            textField.backgroundColor = UIColor.clear
            return textField
        }()
        
        private let datePicker: UIDatePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .time
            picker.preferredDatePickerStyle = .wheels
            picker.locale = Locale(identifier: "ko_KR")
            return picker
        }()
        
        var timeChanged = PassthroughSubject<Date, Never>()
        
        init(placeholder: String) {
            super.init(frame: .zero)
            textField.placeholder = placeholder
            isUserInteractionEnabled = true
            setupUI()
            setupDatePicker()
            setupToolBar()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            addSubViews([containerView, textField])
            
            containerView.isUserInteractionEnabled = false
            containerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(44)
            }
            
            textField.snp.makeConstraints {
                $0.edges.equalTo(containerView).inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            }
        }
        
        private func setupDatePicker() {
            textField.inputView = datePicker
        }
        
        private func setupToolBar() {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: Strings.WriteAdditionalInfo.OpeningHours.done, style: .done, target: self, action: #selector(didTapDone))
            let cancelButton = UIBarButtonItem(title: Strings.WriteAdditionalInfo.OpeningHours.cancel, style: .plain, target: self, action: #selector(didTapCancel))
            
            toolbar.items = [cancelButton, flexSpace, doneButton]
            textField.inputAccessoryView = toolbar
        }
        
        @objc private func didTapDone() {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = Strings.WriteAdditionalInfo.OpeningHours.dateFormat
            let timeString = formatter.string(from: datePicker.date)
            textField.text = timeString
            
            timeChanged.send(datePicker.date)
            textField.resignFirstResponder()
        }
        
        @objc private func didTapCancel() {
            textField.resignFirstResponder()
        }
        
        func setTime(_ date: Date?) {
            guard let date = date else {
                textField.text = nil
                return
            }
            datePicker.date = date
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = Strings.WriteAdditionalInfo.OpeningHours.dateFormat
            textField.text = formatter.string(from: date)
        }
    }
}

final class OpeningHoursSectionView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteAdditionalInfo.OpeningHours.title
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let startTimeField = TimeField(placeholder: Strings.WriteAdditionalInfo.OpeningHours.startTimePlaceholder)
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteAdditionalInfo.OpeningHours.separator
        label.font = Fonts.medium.font(size: 14)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        return label
    }()
    
    private let endTimeField = TimeField(placeholder: Strings.WriteAdditionalInfo.OpeningHours.endTimePlaceholder)
    
    private let untilLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteAdditionalInfo.OpeningHours.until
        label.font = Fonts.medium.font(size: 14)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    var startTimeChanged = PassthroughSubject<Date, Never>()
    var endTimeChanged = PassthroughSubject<Date, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubViews([
            titleLabel,
            startTimeField,
            separatorLabel,
            endTimeField,
            untilLabel
        ])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        startTimeField.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(36)
            $0.trailing.equalTo(separatorLabel.snp.leading).offset(-8)
        }
        
        separatorLabel.snp.makeConstraints {
            $0.centerY.equalTo(startTimeField)
            $0.trailing.equalTo(endTimeField.snp.leading).offset(-16)
        }
        
        endTimeField.snp.makeConstraints {
            $0.leading.equalTo(snp.centerX)
            $0.centerY.equalTo(startTimeField)
            $0.height.equalTo(36)
            $0.trailing.equalTo(untilLabel.snp.leading).offset(-8)
        }
        
        untilLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(endTimeField)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(64)
        }
    }
    
    private func bind() {
        startTimeField.timeChanged
            .sink { [weak self] date in
                self?.startTimeChanged.send(date)
            }
            .store(in: &cancellables)
        
        endTimeField.timeChanged
            .sink { [weak self] date in
                self?.endTimeChanged.send(date)
            }
            .store(in: &cancellables)
    }
    
    func setStartTime(_ date: Date?) {
        startTimeField.setTime(date)
    }
    
    func setEndTime(_ date: Date?) {
        endTimeField.setTime(date)
    }
}
