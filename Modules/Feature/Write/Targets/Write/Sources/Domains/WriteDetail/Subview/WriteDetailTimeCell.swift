import UIKit

import Common
import Model
import DesignSystem

final class WriteDetailTimeCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 72)
    }
    
    let startTimeField = TimeField(placeholder: Strings.writeDetailTimeFromPlaceholder)
    
    private let fromLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 12)
        label.text = Strings.writeDetailTimeFrom
        return label
    }()
    
    let endTimeField = TimeField(placeholder: Strings.writeDetailTimeUntilPlaceholder)
    
    private let untilLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.gray100.color
        label.font = Fonts.medium.font(size: 12)
        label.text = Strings.writeDetailTimeUntil
        return label
    }()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        contentView.addSubViews([
            startTimeField,
            fromLabel,
            endTimeField,
            untilLabel
        ])
    }
    
    override func bindConstraints() {
        startTimeField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
            $0.trailing.equalTo(fromLabel.snp.leading).offset(-8)
        }
        
        fromLabel.snp.makeConstraints {
            $0.trailing.equalTo(snp.centerX).offset(-8)
            $0.centerY.equalTo(startTimeField)
        }
        
        endTimeField.snp.makeConstraints {
            $0.leading.equalTo(fromLabel.snp.trailing).offset(8)
            $0.top.equalTo(startTimeField)
            $0.bottom.equalTo(startTimeField)
            $0.trailing.equalTo(untilLabel.snp.leading).offset(-8)
        }
        
        untilLabel.snp.makeConstraints {
            $0.centerY.equalTo(endTimeField)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bind(viewModel: WriteDetailTimeCellViewModel) {
        startTimeField.didTapDone = { [weak viewModel] startTime in
            viewModel?.input.inputStartDate.send(startTime)
        }
        
        endTimeField.didTapDone = { [weak viewModel] endTime in
            viewModel?.input.inputEndDate.send(endTime)
        }
        
        viewModel.output.inputStartDate
            .withUnretained(self)
            .sink { (cell: WriteDetailTimeCell, startDate: String?) in
                cell.startTimeField.textField.text = startDate
            }
            .store(in: &cancellables)
        
        viewModel.output.inputEndDate
            .withUnretained(self)
            .sink { (cell: WriteDetailTimeCell, endDate: String?) in
                cell.endTimeField.textField.text = endDate
            }
            .store(in: &cancellables)
    }
}


extension WriteDetailTimeCell {
    final class TimeField: BaseView {
        enum Layout {
            static let height: CGFloat = 44
        }
        
        private let containerView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 8
            view.backgroundColor = Colors.gray10.color
            
            return view
        }()
        
        let textField: UITextField = {
            let textField = UITextField()
            textField.textAlignment = .left
            textField.font = Fonts.regular.font(size: 14)
            textField.textColor = Colors.gray100.color
            
            return textField
        }()
        
        private let datePicker = UIDatePicker()
        var didTapDone: ((String) -> Void)? = nil
        
        init(placeholder: String) {
            super.init(frame: .zero)
            
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: Colors.gray50.color]
            )
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setup() {
            setupDatePicker()
            setupToolBar()
            addSubViews([
                containerView,
                textField
            ])
        }
        
        override func bindConstraints() {
            containerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(Layout.height)
            }
            
            textField.snp.makeConstraints {
                $0.leading.equalTo(containerView).offset(12)
                $0.top.equalTo(containerView).offset(12)
                $0.trailing.equalTo(containerView).offset(-12)
                $0.bottom.equalTo(containerView).offset(-12)
            }
            
            snp.makeConstraints {
                $0.height.equalTo(containerView).priority(.high)
            }
        }
        
        private func setupDatePicker() {
            datePicker.datePickerMode = .time
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.locale = Locale.current
            datePicker.minuteInterval = 0
            textField.inputView = datePicker
        }
        
        private func setupToolBar() {
            let toolBar = UIToolbar()
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoen))

            toolBar.items = [flexibleSpace, doneButton]
            toolBar.sizeToFit()
            textField.inputAccessoryView = toolBar
        }
        
        @objc private func didTapDoen() {
            let dateString = DateUtils.toString(date: datePicker.date, format: Strings.writeDetailTimeFormat)
            
            didTapDone?(dateString)
            textField.resignFirstResponder()
        }
    }
}
