import UIKit

import Common
import DesignSystem

import CombineCocoa

final class MenuInputView: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.text = Strings.WriteDetailMenu.Menu.titleFormat(1)
        label.textAlignment = .left
        return label
    }()
    
    private let nameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
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
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let quantityTextField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.regular.font(size: 14)
        textField.textColor = Colors.gray100.color
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
        
        return label
    }()
    
    private let priceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.font = Fonts.regular.font(size: 14)
        textField.textColor = Colors.gray100.color
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
        backgroundColor = Colors.gray10.color
        nameTextField.delegate = self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        addSubViews([
            titleLabel,
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
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
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
            $0.width.equalTo((UIUtils.windowBounds.width - 40 - 8) * 0.4)
            $0.height.equalTo(44)
        }
        
        quantityLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        quantityTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(quantityLabel.snp.leading).offset(-16)
        }
        
        priceContainerView.snp.makeConstraints {
            $0.top.bottom.equalTo(quantityContainerView)
            $0.leading.equalTo(quantityContainerView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.equalTo(13)
        }
        
        priceTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(priceLabel.snp.leading).offset(-16)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(124)
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
        switch textField {
        case nameTextField:
            nameContainerView.layer.borderColor = Colors.mainPink.color.cgColor
            nameContainerView.layer.borderWidth = 1
        case quantityLabel:
            quantityContainerView.layer.borderColor = Colors.mainPink.color.cgColor
            quantityContainerView.layer.borderWidth = 1
        case priceTextField:
            priceContainerView.layer.borderColor = Colors.mainPink.color.cgColor
            priceContainerView.layer.borderWidth = 1
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            nameContainerView.layer.borderWidth = 0
        case quantityLabel:
            quantityContainerView.layer.borderWidth = 0
        case priceTextField:
            priceContainerView.layer.borderWidth = 0
        default:
            break
        }
    }
}
