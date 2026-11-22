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

    private let nameField: TextField = {
        let field = TextField(placeholder: Strings.WriteDetailMenu.Menu.namePlaceholder)
        field.textField.returnKeyType = .done
        return field
    }()

    private let quantityField: TextField = {
        let field = TextField(
            placeholder: Strings.WriteDetailMenu.Menu.quantityPlaceholder,
            suffix: Strings.WriteDetailMenu.Menu.quantity
        )
        field.textField.keyboardType = .numberPad
        field.textField.returnKeyType = .done
        return field
    }()

    private let priceField: TextField = {
        let field = TextField(
            placeholder: Strings.WriteDetailMenu.Menu.pricePlaceholder,
            suffix: Strings.WriteDetailMenu.Menu.price
        )
        field.textField.keyboardType = .decimalPad
        return field
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
        addSubViews([
            titleLabel,
            deleteButton,
            nameField,
            quantityField,
            priceField
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

        nameField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        quantityField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(nameField.snp.bottom).offset(8)
            $0.width.equalTo(Layout.quantityWidth)
        }

        priceField.snp.makeConstraints {
            $0.top.equalTo(quantityField)
            $0.leading.equalTo(quantityField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-20)
        }

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }

    private func bind() {
        nameField.textField.textPublisher
            .subscribe(viewModel.input.inputName)
            .store(in: &cancellables)

        quantityField.textField.textPublisher
            .subscribe(viewModel.input.inputQuantity)
            .store(in: &cancellables)

        priceField.textField.textPublisher
            .subscribe(viewModel.input.inputPrice)
            .store(in: &cancellables)

        deleteButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapDelete)
            .store(in: &cancellables)

        viewModel.output.name
            .main
            .sink { [weak self] name in
                self?.nameField.textField.text = name
            }
            .store(in: &cancellables)

        viewModel.output.price
            .main
            .sink { [weak self] price in
                self?.priceField.textField.text = price?.decimalFormat
            }
            .store(in: &cancellables)

        viewModel.output.quantity
            .main
            .sink { [weak self] quantity in
                self?.quantityField.textField.text = quantity?.decimalFormat
            }
            .store(in: &cancellables)
    }
}
