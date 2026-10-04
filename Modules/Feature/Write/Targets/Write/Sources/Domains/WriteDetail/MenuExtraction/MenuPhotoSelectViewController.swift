import UIKit

import Common
import DesignSystem
import Log

final class MenuPhotoSelectViewController: BaseViewController {
    private let backgroundButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.systemBlack.color.withAlphaComponent(0.2)
        return button
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MenuPhotoSelect.title
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MenuPhotoSelect.description
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 0
        return label
    }()

    private let exampleImageView: UIImageView = {
        let imageView = UIImageView(image: Assets.imageMenuExample.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let albumButton = MenuPhotoSelectViewController.makeButton(
        title: Strings.MenuPhotoSelect.album,
        image: Assets.iconImage.image
    )

    private let cameraButton = MenuPhotoSelectViewController.makeButton(
        title: Strings.MenuPhotoSelect.camera,
        image: Icons.camera.image
    )

    private let viewModel: MenuPhotoSelectViewModel
    private let onTapAlbum: () -> Void
    private let onTapCamera: () -> Void

    override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    init(
        viewModel: MenuPhotoSelectViewModel,
        onTapAlbum: @escaping () -> Void,
        onTapCamera: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onTapAlbum = onTapAlbum
        self.onTapCamera = onTapCamera
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
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
        view.backgroundColor = .clear
        view.addSubViews([
            backgroundButton,
            containerView
        ])
        containerView.addSubViews([
            titleLabel,
            descriptionLabel,
            exampleImageView,
            albumButton,
            cameraButton
        ])

        backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        exampleImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(180)
        }

        albumButton.snp.makeConstraints {
            $0.top.equalTo(exampleImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        cameraButton.snp.makeConstraints {
            $0.top.equalTo(albumButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func bind() {
        backgroundButton.tapPublisher
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        albumButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAlbum)
            .store(in: &cancellables)

        cameraButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapCamera)
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }

    private static func makeButton(title: String, image: UIImage) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 14)
        ]))
        config.image = image
            .resizeImage(scaledTo: 18)
            .withRenderingMode(.alwaysTemplate)
        config.imagePadding = 8
        config.baseForegroundColor = Colors.gray50.color
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12
        config.background.strokeWidth = 1
        config.background.strokeColor = Colors.gray40.color
        return UIButton(configuration: config)
    }
}

// MARK: Route
extension MenuPhotoSelectViewController {
    private func handleRoute(_ route: MenuPhotoSelectViewModel.Route) {
        let action: () -> Void
        switch route {
        case .album:
            action = onTapAlbum
        case .camera:
            action = onTapCamera
        }
        dismiss(animated: true) {
            action()
        }
    }
}
