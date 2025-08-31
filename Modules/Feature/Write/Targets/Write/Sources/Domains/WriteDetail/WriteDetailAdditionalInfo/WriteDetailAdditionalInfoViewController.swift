import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit

final class WriteDetailAdditionalInfoViewController: BaseViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 0, right: 20)
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color
        
        let string = Strings.WriteAdditionalInfo.title
        var attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: Fonts.bold.font(size: 24),
            .foregroundColor: Colors.gray100.color
        ])
        
        let range = (string as NSString).range(of: Strings.WriteAdditionalInfo.titleSmallerRange)
        attributedString.addAttribute(.font, value: Fonts.bold.font(size: 16), range: range)
        attributedString.addAttribute(.foregroundColor, value: Colors.gray50.color, range: range)
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.text = Strings.WriteAdditionalInfo.description
        label.textAlignment = .left
        return label
    }()
    
    private lazy var paymentMothodView = PaymentMethodSectionView()
    private lazy var appearanceDayView = AppearanceDaysSectionView()
    private lazy var openingHoursView = OpeningHoursSectionView()
    
    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteAdditionalInfo.skip, attributes: AttributeContainer([
            .font: Fonts.medium.font(size: 16),
            .foregroundColor: Colors.gray70.color
        ]))
        config.image = Icons.arrowRight.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Colors.gray70.color)
            .resizeImage(scaledTo: 16)
        config.imagePadding = 4
        
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let finishButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteAdditionalInfo.Finish.normal, attributes: AttributeContainer([
            .font: Fonts.bold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.backgroundColor = Colors.mainPink.color
        button.layer.masksToBounds = true
        return button
    }()
    
    private let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        return view
    }()
    
    private let viewModel: WriteDetailAdditionalInfoViewModel
    
    init(viewModel: WriteDetailAdditionalInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            scrollView,
            finishButton,
            skipButton,
            buttonBackground
        ])
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel, previousSpace: 8)
        stackView.addArrangedSubview(paymentMothodView, previousSpace: 36)
        stackView.addArrangedSubview(appearanceDayView, previousSpace: 20)
        stackView.addArrangedSubview(openingHoursView, previousSpace: 20)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(finishButton.snp.top)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
        
        skipButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(finishButton.snp.top)
            $0.height.equalTo(48)
        }
        
        finishButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.isNavigationBarHidden = false
        
        if viewModel.output.afterCreatedStore {
            title = Strings.WriteAdditionalInfo.Navigation.Title.afterCreated
            navigationController.setProgressHidden(true)
            navigationItem.rightBarButtonItem = nil
        } else {
            title = Strings.WriteAdditionalInfo.Navigation.Title.normal
            navigationController.updateProgress(1.0)
            navigationController.setProgressHidden(false)
            
            let closeImage = DesignSystemAsset.Icons.close.image
                .resizeImage(scaledTo: 24)
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.white)
            let closeButtonItem = UIBarButtonItem(
                image: closeImage,
                style: .plain,
                target: self,
                action: #selector(didTapClose)
            )
            closeButtonItem.tintColor = Colors.gray100.color
            navigationItem.setAutoInsetRightBarButtonItem(closeButtonItem)
        }
    }
    
    private func bind() {
        bindAfterCreateStore(viewModel.output.afterCreatedStore)
        // Input
        finishButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapFinish)
            .store(in: &cancellables)
        
        paymentMothodView.selectedPaymentMethods
            .subscribe(viewModel.input.didSelectPaymentMethod)
            .store(in: &cancellables)
        
        appearanceDayView.selectedDayChanged
            .subscribe(viewModel.input.didSelectAppearanceDay)
            .store(in: &cancellables)
        
        openingHoursView.startTimeChanged
            .removeDuplicates()
            .subscribe(viewModel.input.didSelectStartTime)
            .store(in: &cancellables)
        
        openingHoursView.endTimeChanged
            .removeDuplicates()
            .subscribe(viewModel.input.didSelectEndTime)
            .store(in: &cancellables)
        
        skipButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSkip)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.selectedPaymentMethods
            .main
            .sink { [weak self] paymentMethods in
                self?.paymentMothodView.selectPaymentMethods(paymentMethods)
            }
            .store(in: &cancellables)
        
        viewModel.output.selectedDays
            .main
            .sink { [weak self] appearanceDays in
                self?.appearanceDayView.selectDays(appearanceDays)
            }
            .store(in: &cancellables)
        
        viewModel.output.selectedStartTime
            .main
            .sink { [weak self] date in
                self?.openingHoursView.setStartTime(date)
            }
            .store(in: &cancellables)
        
        viewModel.output.selectedEndTime
            .main
            .sink { [weak self] date in
                self?.openingHoursView.setEndTime(date)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func bindAfterCreateStore(_ afterCreateStore: Bool) {
        let string = afterCreateStore ? "작성 완료" : "다음"
        finishButton.configuration?.attributedTitle = AttributedString(string, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        skipButton.isHidden = afterCreateStore
    }
    
    @objc private func didTapClose() {
        presentDismissModal()
    }
}

// MARK: Route
extension WriteDetailAdditionalInfoViewController {
    private func handleRoute(_ route: WriteDetailAdditionalInfoViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func presentDismissModal() {
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }
}
