import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreDetailVisitInducementModalView: BaseView, DismissibleStoreDetailModal {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 20
        view.layer.borderColor = Colors.gray20.color.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.masksToBounds = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private let closedButton = VisitInducementChoiceButton(
        backgroundColor: Colors.gray0.color,
        titleColor: Colors.mainPink.color,
        icon: Assets.imageFailVisit.image
    )

    private let openedButton = VisitInducementChoiceButton(
        backgroundColor: Colors.gray0.color,
        titleColor: Colors.mainGreen.color,
        icon: Assets.imageSuccessVisit.image
    )

    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [closedButton, openedButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private var viewModel: StoreDetailVisitInducementModalViewModel?

    override func setup() {
        super.setup()
        backgroundColor = .clear

        addSubview(containerView)
        containerView.addSubViews([
            titleLabel,
            subtitleLabel,
            buttonStackView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(84)
        }
    }

    func bind(viewModel: StoreDetailVisitInducementModalViewModel) {
        self.viewModel = viewModel
        cancellables.removeAll()

        titleLabel.text = viewModel.output.title
        subtitleLabel.text = viewModel.output.subtitle
        closedButton.setTitle(viewModel.output.closedButtonTitle)
        openedButton.setTitle(viewModel.output.openedButtonTitle)

        closedButton.controlPublisher(for: .touchUpInside)
            .map { _ in VisitType.notExists }
            .subscribe(viewModel.input.didTapVisit)
            .store(in: &cancellables)

        openedButton.controlPublisher(for: .touchUpInside)
            .map { _ in VisitType.exists }
            .subscribe(viewModel.input.didTapVisit)
            .store(in: &cancellables)

        viewModel.output.isInteractable
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner, interactable) in
                owner.closedButton.isEnabled = interactable
                owner.openedButton.isEnabled = interactable
            }
            .store(in: &cancellables)
    }
}

final class VisitInducementChoiceButton: UIControl {
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()

    init(backgroundColor: UIColor?, titleColor: UIColor?, icon: UIImage?) {
        super.init(frame: .zero)

        self.backgroundColor = backgroundColor
        layer.cornerRadius = 12
        layer.borderColor = Colors.gray20.color.cgColor
        layer.borderWidth = 1
        clipsToBounds = true

        iconView.image = icon
        titleLabel.textColor = titleColor

        addSubview(iconView)
        addSubview(titleLabel)

        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
}
