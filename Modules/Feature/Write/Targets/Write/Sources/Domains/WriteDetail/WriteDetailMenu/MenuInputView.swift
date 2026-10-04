import UIKit

import Common
import DesignSystem

import CombineCocoa

final class MenuInputView: BaseView {
    enum Layout {
        static let height: CGFloat = 140
        static let quantityWidth: CGFloat = 90
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.textAlignment = .left
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.WriteDetailMenu.Menu.delete, for: .normal)
        button.setTitleColor(Colors.mainRed.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        return button
    }()

    private let nameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.regular.font(size: 14)
        textField.textColor = Colors.gray90.color
        textField.attributedPlaceholder = NSAttributedString(string: Strings.WriteDetailMenu.Menu.namePlaceholder, attributes: [
            .foregroundColor: Colors.gray50.color
        ])
        textField.tintColor = Colors.mainPink.color
        textField.returnKeyType = .done
        return textField
    }()

    private let quantityContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let quantityTextField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.regular.font(size: 14)
        textField.textColor = Colors.gray90.color
        textField.keyboardType = .numberPad
        textField.attributedPlaceholder = NSAttributedString(string: Strings.WriteDetailMenu.Menu.quantityPlaceholder, attributes: [
            .foregroundColor: Colors.gray50.color
        ])
        textField.tintColor = Colors.mainPink.color
        textField.returnKeyType = .done
        return textField
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteDetailMenu.Menu.quantity
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray90.color
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let priceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.regular.font(size: 14)
        textField.textColor = Colors.gray90.color
        textField.keyboardType = .decimalPad
        textField.attributedPlaceholder = NSAttributedString(string: Strings.WriteDetailMenu.Menu.pricePlaceholder, attributes: [
            .foregroundColor: Colors.gray50.color
        ])
        textField.tintColor = Colors.mainPink.color
        return textField
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteDetailMenu.Menu.price
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray90.color
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let viewModel: MenuInputViewModel

    init(viewModel: MenuInputViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupUI()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = Colors.systemWhite.color
        titleLabel.text = Strings.WriteDetailMenu.Menu.titleFormat(viewModel.output.index + 1)
        nameTextField.delegate = self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        addSubViews([
            titleLabel,
            deleteButton,
            nameContainerView,
            quantityContainerView,
            priceContainerView
        ])

        nameContainerView.addSubview(nameTextField)
        quantityContainerView.addSubViews([
            quantityTextField,
            quantityLabel
        ])
        priceContainerView.addSubViews([
            priceTextField,
            priceLabel
        ])

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(deleteButton.snp.leading).offset(-8)
            $0.height.equalTo(20)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.height.equalTo(20)
        }

        nameContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(44)
        }

        nameTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(12)
        }

        quantityContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(nameContainerView.snp.bottom).offset(8)
            $0.width.equalTo(Layout.quantityWidth)
            $0.height.equalTo(44)
        }

        quantityLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }

        quantityTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(quantityLabel.snp.leading).offset(-8)
        }

        priceContainerView.snp.makeConstraints {
            $0.top.bottom.equalTo(quantityContainerView)
            $0.leading.equalTo(quantityContainerView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-20)
        }

        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }

        priceTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(priceLabel.snp.leading).offset(-16)
        }

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }

    private func bind() {
        nameTextField.textPublisher
            .subscribe(viewModel.input.inputName)
            .store(in: &cancellables)

        quantityTextField.textPublisher
            .subscribe(viewModel.input.inputQuantity)
            .store(in: &cancellables)

        priceTextField.textPublisher
            .subscribe(viewModel.input.inputPrice)
            .store(in: &cancellables)

        deleteButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapDelete)
            .store(in: &cancellables)

        viewModel.output.name
            .main
            .sink { [weak self] name in
                self?.nameTextField.text = name
            }
            .store(in: &cancellables)

        viewModel.output.price
            .main
            .sink { [weak self] price in
                self?.priceTextField.text = price?.decimalFormat
            }
            .store(in: &cancellables)

        viewModel.output.quantity
            .main
            .sink { [weak self] quantity in
                self?.quantityTextField.text = quantity?.decimalFormat
            }
            .store(in: &cancellables)
    }
}

extension MenuInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        containerView(of: textField)?.layer.borderColor = Colors.mainPink.color.cgColor
        containerView(of: textField)?.layer.borderWidth = 1
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        containerView(of: textField)?.layer.borderWidth = 0
    }

    private func containerView(of textField: UITextField) -> UIView? {
        switch textField {
        case nameTextField:
            return nameContainerView
        case quantityTextField:
            return quantityContainerView
        case priceTextField:
            return priceContainerView
        default:
            return nil
        }
    }
}
