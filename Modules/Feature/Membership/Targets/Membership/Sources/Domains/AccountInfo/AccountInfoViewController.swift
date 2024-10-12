import UIKit

import Common
import Model
import Log
import DesignSystem

import CombineCocoa
import PanModal

final class AccountInfoViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let laterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.setTitleColor(Colors.gray70.color, for: .normal)
        button.setTitle(Strings.AccountInfo.later, for: .normal)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 14, left: 32, bottom: 0, right: 32)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray0.color
        label.numberOfLines = 2
        label.text = Strings.AccountInfo.Main.title
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray50.color
        label.numberOfLines = 2
        label.text = Strings.AccountInfo.Main.description
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 30)
        label.textColor = Colors.systemWhite.color
        return label
    }()
    
    private let secondLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        return stackView
    }()
    
    private let birthdayYearButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icArrowDown.image, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 30)
        button.backgroundColor = Colors.pink500.color
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.contentEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private let secondLineLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 30)
        label.textColor = Colors.systemWhite.color
        label.text = Strings.AccountInfo.Main.second
        label.textAlignment = .left
        return label
    }()
    
    private let thirdLineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let genderButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 30)
        button.backgroundColor = Colors.pink500.color
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.contentEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
        return button
    }()
    
    private let thirdLineLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 30)
        label.textColor = Colors.systemWhite.color
        label.text = Strings.AccountInfo.Main.third
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(Colors.gray80.color, for: .disabled)
        button.setBackgroundColor(Colors.mainPink.color, for: .normal)
        button.setTitle(Strings.AccountInfo.save, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        button.setTitleColor(Colors.gray60.color, for: .disabled)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let buttonBackground = UIView()
    
    private let viewModel: AccountInfoViewModel
    
    public init(viewModel: AccountInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        viewModel.input.firstLoad.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.gray100.color
        setupNavigationBar()
        
        guard let navigationBar else { return }
        
        stackView.addArrangedSubview(nicknameLabel)
        stackView.setCustomSpacing(6, after: nicknameLabel)
        
        secondLineStackView.addArrangedSubview(birthdayYearButton)
        secondLineStackView.addArrangedSubview(secondLineLabel)
        
        stackView.addArrangedSubview(secondLineStackView)
        stackView.setCustomSpacing(6, after: secondLineStackView)
        
        thirdLineStackView.addArrangedSubview(genderButton)
        thirdLineStackView.addArrangedSubview(thirdLineLabel)
        
        stackView.addArrangedSubview(thirdLineStackView)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(navigationBar.snp.bottom)
        }
        
        view.addSubview(buttonBackground)
        buttonBackground.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
    }
    
    private func setupNavigationBar() {
        addNavigationBar()
        navigationBar?.tintColor = Colors.systemWhite.color
        if viewModel.config.shouldPush {
            navigationItem.title = Strings.AccountInfo.title
        } else {
            let barButtonItem = UIBarButtonItem(title: Strings.AccountInfo.later, style: .plain, target: self, action: #selector(didTapLater))
            barButtonItem.setTitleTextAttributes([
                .font: Fonts.medium.font(size: 12),
                .foregroundColor: Colors.gray70.color
            ], for: .normal)
            navigationItem.setAutoInsetRightBarButtonItem(barButtonItem)
        }
    }
    
    private func bind() {
        // Input
        birthdayYearButton.tapPublisher
            .subscribe(viewModel.input.didTapBirthday)
            .store(in: &cancellables)
        
        genderButton.tapPublisher
            .subscribe(viewModel.input.didTapGender)
            .store(in: &cancellables)
        
        saveButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSave)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.showDescription
            .main
            .withUnretained(self)
            .sink { (owner: AccountInfoViewController, _) in
                owner.showDescription()
            }
            .store(in: &cancellables)
        
        viewModel.output.birthdayYear
            .main
            .withUnretained(self)
            .sink { (owner: AccountInfoViewController, year: Int?) in
                owner.setBirthdayYear(year: year)
            }
            .store(in: &cancellables)
        
        viewModel.output.gender
            .main
            .withUnretained(self)
            .sink { (owner: AccountInfoViewController, gender: Gender?) in
                owner.setGender(gender: gender)
            }
            .store(in: &cancellables)
        
        viewModel.output.nickname
            .main
            .withUnretained(self)
            .sink { (owner: AccountInfoViewController, nickname: String) in
                owner.setNickname(nickname: nickname)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnableSaveButton
            .main
            .withUnretained(self)
            .sink { (owner: AccountInfoViewController, isEnable: Bool) in
                owner.setSaveButtonEnable(isEnable: isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { (message: String) in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: AccountInfoViewController, route: AccountInfoViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func showDescription() {
        stackView.insertArrangedSubview(titleLabel, at: 0)
        stackView.setCustomSpacing(9, after: titleLabel)
        stackView.insertArrangedSubview(descriptionLabel, at: 1)
        stackView.setCustomSpacing(49, after: descriptionLabel)
    }
    
    private func setBirthdayYear(year: Int?) {
        let yearString: String
        if let year {
            yearString = Strings.AccountInfo.birthdayYearFormat("\(year)")
        } else {
            yearString = Strings.AccountInfo.birthdayYearFormat("????")
        }
        birthdayYearButton.setTitle(yearString, for: .normal)
    }
    
    private func setGender(gender: Gender?) {
        let genderString: String
        
        if let gender {
            switch gender {
            case .male:
                genderString = Strings.AccountInfo.male
            case .female:
                genderString = Strings.AccountInfo.female
            }
        } else {
            genderString = Strings.AccountInfo.unknownGender
        }
        
        genderButton.setTitle(genderString, for: .normal)
    }
    
    private func setNickname(nickname: String) {
        nicknameLabel.text = Strings.AccountInfo.nicknameFormat(nickname)
    }
    
    private func setSaveButtonEnable(isEnable: Bool) {
        saveButton.isEnabled = isEnable
        buttonBackground.backgroundColor = isEnable ? Colors.mainPink.color : Colors.gray80.color
    }
    
    @objc private func didTapLater() {
        viewModel.input.didTapLater.send(())
    }
}
 
extension AccountInfoViewController {
    private func handleRoute(_ route: AccountInfoViewModel.Route) {
        switch route {
        case .back:
            navigationController?.popViewController(animated: true)
        case .dismiss:
            dismiss(animated: true)
        case .showYearPicker(let viewModel):
            presentBirthdayYearBottomSheet(viewModel: viewModel)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func presentBirthdayYearBottomSheet(viewModel: BirthdayYearBottomSheetViewModel) {
        let picker = BirthdayYearBottomSheetViewController(viewModel: viewModel)
        
        presentPanModal(picker)
    }
}
