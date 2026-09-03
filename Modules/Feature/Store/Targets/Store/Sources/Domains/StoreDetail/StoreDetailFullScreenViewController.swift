import UIKit
import CoreLocation

import AppInterface
import Common
import DesignSystem

import SnapKit

/// V2 SDUI 가게 상세를 지도/시트 없이 전체 화면으로 보여주는 컨테이너.
final class StoreDetailFullScreenViewController: BaseViewController {
    private let storeId: Int
    private let sectionsViewController: StoreSectionsViewController

    private let detailNavigationBar = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.textAlignment = .center
        label.alpha = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let backButton = StoreDetailFullScreenViewController.makeNavigationButton(icon: Icons.arrowLeft.image)
    private let shareButton = StoreDetailFullScreenViewController.makeNavigationButton(icon: Icons.share.image)
    private let closeButton = StoreDetailFullScreenViewController.makeNavigationButton(icon: Icons.close.image)

    private var storeName = ""
    private var storeLocation: CLLocationCoordinate2D?

    init(storeId: Int, latitude: Double, longitude: Double) {
        self.storeId = storeId
        self.sectionsViewController = StoreSectionsViewController(
            storeId: storeId,
            latitude: latitude,
            longitude: longitude
        )
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindSections()
        setupActions()
    }

    private func setupViews() {
        view.backgroundColor = Colors.systemWhite.color
        detailNavigationBar.backgroundColor = Colors.systemWhite.color

        addChild(sectionsViewController)
        view.addSubview(sectionsViewController.view)
        sectionsViewController.didMove(toParent: self)

        view.addSubview(detailNavigationBar)
        [backButton, titleLabel, shareButton, closeButton].forEach { detailNavigationBar.addSubview($0) }

        detailNavigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }

        // 상세는 네비 아래에서 시작한다. 네비와 겹치면 가게명이 가려지고,
        // 스크롤 시 상태바 영역까지 컨텐츠가 비쳐 보인다.
        sectionsViewController.view.snp.makeConstraints {
            $0.top.equalTo(detailNavigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }
        shareButton.snp.makeConstraints {
            $0.trailing.equalTo(closeButton.snp.leading).offset(-4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(12)
            $0.trailing.equalTo(shareButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
    }

    private func bindSections() {
        sectionsViewController.onScrollOffsetChanged = { [weak self] offset in
            guard let self else { return }
            self.titleLabel.alpha = min(max(offset / 48, 0), 1)
            self.view.bringSubviewToFront(self.detailNavigationBar)
        }
        sectionsViewController.onStoreInformationChanged = { [weak self] title, location in
            self?.storeName = title?.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) ?? ""
            self?.storeLocation = location
            self?.titleLabel.setSDText(title, customFont: Fonts.semiBold.font(size: 16))
            guard let self else { return }
            self.view.bringSubviewToFront(self.detailNavigationBar)
        }
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapShare() {
        let location = storeLocation ?? .init(latitude: 0, longitude: 0)
        Environment.appModuleInterface.shareKakao(
            storeId: storeId,
            storeName: storeName,
            latitude: location.latitude,
            longitude: location.longitude
        )
    }

    @objc private func didTapClose() {
        if let navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private static func makeNavigationButton(icon: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(icon.resizeImage(scaledTo: 20).withTintColor(Colors.gray100.color), for: .normal)
        return button
    }
}
