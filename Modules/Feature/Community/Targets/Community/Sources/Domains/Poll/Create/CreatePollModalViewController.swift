import UIKit

import Then
import Common
import DesignSystem

final class CreatePollModalViewController: BaseViewController {

    enum Constant {
        static let maxTitleCount: Int = 20
    }

    private let backgroundView = UIView()

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .white
    }

    private let countLabel = UILabel().then {
        $0.text = "0"
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }

    private let maxCountLabel = UILabel().then {
        $0.text = "/\(Constant.maxTitleCount)"
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray30.color
    }

    private lazy var titleTextField = UITextField().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.backgroundColor = .clear
        $0.textColor = Colors.gray100.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "투표 제목을 입력하세요",
            attributes: [
                .font: Fonts.semiBold.font(size: 20),
                .foregroundColor: Colors.gray30.color
            ])
        $0.delegate = self
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private lazy var firstOptionTextField = CreatePollOptionTextField(
        padding: .init(top: 12, left: 16, bottom: 12, right: 16)
    ).then {
        $0.font = Fonts.regular.font(size: 14)
        $0.backgroundColor = Colors.gray10.color
        $0.textColor = Colors.gray100.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "ex) 슈붕",
            attributes: [
                .font: Fonts.regular.font(size: 14),
                .foregroundColor: Colors.gray40.color
            ])
        $0.layer.cornerRadius = 12
        $0.delegate = self
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private lazy var secondOptionTextField = CreatePollOptionTextField(
        padding: .init(top: 12, left: 16, bottom: 12, right: 16)
    ).then {
        $0.font = Fonts.regular.font(size: 14)
        $0.backgroundColor = Colors.gray10.color
        $0.textColor = Colors.gray100.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "ex) 팥붕",
            attributes: [
                .font: Fonts.regular.font(size: 14),
                .foregroundColor: Colors.gray40.color
            ])
        $0.layer.cornerRadius = 12
        $0.delegate = self
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
        $0.numberOfLines = 0
        $0.setLineHeight(lineHeight: 18)
        let style = NSMutableParagraphStyle()

        style.maximumLineHeight = 18
        style.minimumLineHeight = 18

        let text = "* 투표는 3일 동안만 진행돼요\n* 1일 1회만 올릴 수 있어요\n* 부적절한 내용일 경우 임의로 삭제될 수 있어요"
        let attributedText = NSMutableAttributedString(string: text, attributes: [.paragraphStyle: style])
        attributedText.addAttribute(
            .foregroundColor,
            value: Colors.gray100.color,
            range: (text as NSString).range(of: "3일 동안")
        )
        attributedText.addAttribute(
            .foregroundColor,
            value: Colors.gray100.color,
            range: (text as NSString).range(of: "1일 1회")
        )
        $0.attributedText = attributedText
    }

    private lazy var buttonStackView = UIStackView(
        arrangedSubviews: [cancelButton, createButton]
    ).then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(Colors.gray50.color, for: .normal)
        $0.titleLabel?.font = Fonts.semiBold.font(size: 14)
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.gray40.color.cgColor
    }

    private let createButton = Button.Normal(size: .h48, text: "투표 만들기").then {
        $0.isEnabled = false
    }

    private var containerMinY: CGFloat = 0

    private let viewModel: CreatePollModalViewModel

    init(viewModel: CreatePollModalViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }

        setupUI()
    }

    private func setupUI() {
        containerView.addSubViews([
            titleTextField,
            countLabel,
            maxCountLabel,
            firstOptionTextField,
            secondOptionTextField,
            descriptionLabel,
            buttonStackView
        ])

        view.addSubViews([
            backgroundView,
            containerView
        ])

        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.center.equalToSuperview()
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(60)
        }

        maxCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(titleTextField)
        }

        countLabel.snp.makeConstraints {
            $0.trailing.equalTo(maxCountLabel.snp.leading)
            $0.centerY.equalTo(titleTextField)
        }

        firstOptionTextField.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        secondOptionTextField.snp.makeConstraints {
            $0.top.equalTo(firstOptionTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(secondOptionTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(20)
        }

        addKeyboardObservers()

        view.layoutIfNeeded()
        containerMinY = containerView.frame.minY
    }

    override func bindEvent() {
        super.bindEvent()

        backgroundView.gesture(.tap()).mapVoid
            .merge(with: cancelButton.controlPublisher(for: .touchUpInside).mapVoid)
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)

        // Input
        createButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapCreateButton)
            .store(in: &cancellables)

        // Output
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.isEnabledCreateButton
            .main
            .withUnretained(self)
            .sink { owner, isEnabled in
                owner.createButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .back:
                    owner.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)

        DimManager.shared.hideDim()
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardFrame
                = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        containerView.transform = CGAffineTransform(
            translationX: 0,
            y: -abs(containerMinY - keyboardFrame.cgRectValue.height)
        )
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        containerView.transform = .identity
    }

    @objc func textFieldDidChange(_ sender: UITextField) {
        switch sender {
        case titleTextField:
            viewModel.input.title.send(sender.text ?? "")
            let textCount = sender.text?.count ?? 0
            countLabel.text = "\(textCount)"
            countLabel.textColor = textCount > 0 ? Colors.mainPink.color : Colors.gray60.color
        case firstOptionTextField:
            viewModel.input.firstOption.send(sender.text ?? "")
        case secondOptionTextField:
            viewModel.input.secondOption.send(sender.text ?? "")
        default:
            break
        }
    }
}

// MARK: UITextFieldDelegate
extension CreatePollModalViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, textField == titleTextField else { return true }

        let newLength = text.countWithoutWhitespace + string.countWithoutWhitespace - range.length
        if newLength > Constant.maxTitleCount {
            ToastManager.shared.show(message: "\(Constant.maxTitleCount)자 이상 입력할 수 없어요.")
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CreatePollOptionTextField
private final class CreatePollOptionTextField: UITextField {
    let textPadding: UIEdgeInsets

    init(padding: UIEdgeInsets) {
        self.textPadding = padding
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

private extension String {
    var removeAllWhitespace: String {
        self.filter { !$0.isWhitespace }
    }

    var countWithoutWhitespace: Int {
        removeAllWhitespace.count
    }
}
