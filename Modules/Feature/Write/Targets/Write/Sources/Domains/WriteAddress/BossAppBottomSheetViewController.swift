import UIKit

import Common
import DesignSystem
import Log

import PanModal

final class BossAppBottomSheetViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.text = Strings.BossAppBottomSheet.title
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.iconClose.image
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderColor = Colors.mainGreen.color.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = Colors.systemWhite.color
        return view
    }()

    private let descriptionLabel: UILabel = {
        let string = Strings.BossAppBottomSheet.description
        let attributedString = NSMutableAttributedString(string: string)
        let coloredRange = (string as NSString).range(of: Strings.BossAppBottomSheet.greenDescription)
        attributedString.addAttribute(.foregroundColor, value: Colors.mainGreen.color, range: coloredRange)
        
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray80.color
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()

    private let firstFeatureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        let strings = [Strings.BossAppBottomSheet.Feature.message, Strings.BossAppBottomSheet.Feature.information]
        for string in strings {
            let label = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
            label.backgroundColor = Colors.gray10.color
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray70.color
            label.text = string
            label.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()
    
    private let secondFeatureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        let strings = [Strings.BossAppBottomSheet.Feature.notice, Strings.BossAppBottomSheet.Feature.review]
        for string in strings {
            let label = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
            label.backgroundColor = Colors.gray10.color
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray70.color
            label.text = string
            label.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()
    
    private let thirdFeatureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        let strings = [Strings.BossAppBottomSheet.Feature.live]
        for string in strings {
            let label = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
            label.backgroundColor = Colors.gray10.color
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray70.color
            label.text = string
            label.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()

    private let installButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = Colors.mainGreen.color
        config.attributedTitle = AttributedString(Strings.BossAppBottomSheet.install, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 14),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = Colors.mainGreen.color
        return button
    }()

    override var screenName: ScreenName {
        return .writeAddressBossBottomSheet
    }
    private let viewModel: BossAppBottomSheetViewModel

    init(viewModel: BossAppBottomSheetViewModel) {
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

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            titleLabel,
            closeButton,
            containerView,
            installButton
        ])
        containerView.addSubViews([
            descriptionLabel,
            firstFeatureStackView,
            secondFeatureStackView,
            thirdFeatureStackView
        ])

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-20)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(136)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        firstFeatureStackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.height.equalTo(24)
        }
        
        secondFeatureStackView.snp.makeConstraints {
            $0.top.equalTo(firstFeatureStackView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(12)
            $0.height.equalTo(24)
        }
        
        thirdFeatureStackView.snp.makeConstraints {
            $0.top.equalTo(secondFeatureStackView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(12)
            $0.height.equalTo(24)
        }
        
        installButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(containerView.snp.bottom).offset(24)
            $0.height.equalTo(48)
        }
    }

    private func bind() {
        closeButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        installButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapInstall)
            .store(in: &cancellables)
        
        viewModel.output.openUrl
            .receive(on: DispatchQueue.main)
            .sink { url in
                guard let url = URL(string: url) else { return }
                UIApplication.shared.open(url)
            }
            .store(in: &cancellables)
    }
    
    private func addHorizontalStackView(strings: [String]) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        for string in strings {
            let label = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
            label.backgroundColor = Colors.gray10.color
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray70.color
            label.text = string
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            stackView.addArrangedSubview(label)
        }
        firstFeatureStackView.addArrangedSubview(stackView)
    }
}

extension BossAppBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? { nil }
    
    var shortFormHeight: PanModalHeight { .contentHeight(310) }
    
    var longFormHeight: PanModalHeight { shortFormHeight }
    
    var cornerRadius: CGFloat { 24 }
    
    var showDragIndicator: Bool { false }
}
