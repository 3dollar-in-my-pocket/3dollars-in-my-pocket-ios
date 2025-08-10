import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit

final class WriteCompleteViewController: BaseViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = WriteAsset.iconClap.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새로운 길거리 음식점을\n제보했어요"
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let overviewContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.gray30.color.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "봉어빵 2번 출구 상가 근처 봉어빵집"
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        return label
    }()
    
    private let storeCategoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "이 업체에 대해 더 알려주세요!"
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray80.color
        label.textAlignment = .center
        return label
    }()
    
    private let addStoreMenuButton = WriteCompleteAdditionalButton(
        icon: WriteAsset.iconForkKnife.image,
        title: "메뉴 상세 정보 추가하기",
        description: "메뉴명 ∙ 메뉴 가격"
    )
    
    private let addAdditionalInfoButton = WriteCompleteAdditionalButton(
        icon: WriteAsset.iconMegaphone.image,
        title: "가게 세부 정보 추가하기",
        description: "가게 형태 ∙ 결제 방식 ∙ 출몰 요일 ∙ 출몰 시간대"
    )
    
    private let completeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("완료", attributes: AttributeContainer([
            .font: Fonts.bold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.backgroundColor = Colors.mainPink.color
        return button
    }()
    
    private let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        return view
    }()
    
    private let viewModel: WriteCompleteViewModel
    
    init(viewModel: WriteCompleteViewModel) {
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
            stackView,
            completeButton,
            buttonBackground
        ])
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(56)
        }
        
        // Icon container
        let iconContainer = UIView()
        iconContainer.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        iconContainer.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(titleLabel, previousSpace: 4)
        stackView.addArrangedSubview(overviewContainer, previousSpace: 12)
        
        overviewContainer.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        overviewContainer.addSubViews([
            storeNameLabel,
            storeCategoryStackView
        ])
        
        stackView.addArrangedSubview(descriptionLabel, previousSpace: 28)
        stackView.addArrangedSubview(addStoreMenuButton, previousSpace: 12)
        stackView.addArrangedSubview(addAdditionalInfoButton, previousSpace: 8)
        
        completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(completeButton.snp.bottom)
        }
    }
    
    private func bind() {
//        // Input
//        addStoreMenuButton.tapPublisher
//            .throttleClick()
//            .subscribe(viewModel.input.didTapMenuDetail)
//            .store(in: &cancellables)
//        
//        storeDetailButton.tapPublisher
//            .throttleClick()
//            .subscribe(viewModel.input.didTapStoreDetail)
//            .store(in: &cancellables)
//        
//        completeButton.tapPublisher
//            .throttleClick()
//            .subscribe(viewModel.input.didTapComplete)
//            .store(in: &cancellables)
//        
//        // Output
//        viewModel.output.route
//            .main
//            .sink { [weak self] route in
//                self?.handleRoute(route)
//            }
//            .store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.setProgressHidden(true)
        navigationController.isNavigationBarHidden = true
    }
    
//    private func updateMenuDetailButton(status: WriteCompleteDetailStatus, iconImageView: UIImageView, subtitleLabel: UILabel) {
//        switch status {
//        case .notAdded:
//            iconImageView.image = DesignSystemAsset.Icons.plus.image
//            iconImageView.tintColor = Colors.gray60.color
//            subtitleLabel.text = "메뉴명 · 메뉴 가격"
//            addStoreMenuButton.layer.borderColor = Colors.gray30.color.cgColor
//            
//        case .added:
//            iconImageView.image = DesignSystemAsset.Icons.check.image
//            iconImageView.tintColor = Colors.mainGreen.color
//            subtitleLabel.text = "작성 완료"
//            addStoreMenuButton.layer.borderColor = Colors.mainGreen.color.cgColor
//        }
//    }
//    
//    private func updateStoreDetailButton(status: WriteCompleteDetailStatus, iconImageView: UIImageView, subtitleLabel: UILabel) {
//        switch status {
//        case .notAdded:
//            iconImageView.image = DesignSystemAsset.Icons.plus.image
//            iconImageView.tintColor = Colors.gray60.color
//            subtitleLabel.text = "가게 형태 · 결제 방식 · 출몰 요일 · 출몰 시간대"
//            addStoreMenuButton.layer.borderColor = Colors.gray30.color.cgColor
//            
//        case .added:
//            iconImageView.image = DesignSystemAsset.Icons.check.image
//            iconImageView.tintColor = Colors.mainGreen.color
//            subtitleLabel.text = "작성 완료"
//            addAdditionalInfoButton.layer.borderColor = Colors.mainGreen.color.cgColor
//        }
//    }
}

// MARK: Route
extension WriteCompleteViewController {
    private func handleRoute(_ route: WriteCompleteViewModel.Route) {
        switch route {
        case .pushWriteDetailMenu(let viewModel):
            pushWriteDetailMenu(viewModel)
        case .pushWriteDetailAdditionalInfo(let viewModel):
            pushWriteDetailAdditionalInfo(viewModel)
        case .dismiss:
            dismiss(animated: true)
        }
    }
    
    private func pushWriteDetailMenu(_ viewModel: WriteDetailMenuViewModel) {
        let viewController = WriteDetailMenuViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushWriteDetailAdditionalInfo(_ viewModel: WriteDetailAdditionalInfoViewModel) {
        let viewController = WriteDetailAdditionalInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
