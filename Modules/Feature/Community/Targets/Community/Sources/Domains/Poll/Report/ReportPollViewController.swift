import Foundation
import UIKit
import Combine

import Then
import Common
import DesignSystem
import Log

final class ReportPollViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    enum Layout {
        static func listHeight(hasReasonDetail: Bool) -> CGFloat {
            if hasReasonDetail {
                return 244 + 86
            } else {
                return 244
            }
        }
    }

    private let backgroundButton = UIButton()

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private let titleLabel = UILabel().then {
        $0.text = "신고 사유"
        $0.textColor = Colors.gray100.color
        $0.font = Fonts.semiBold.font(size: 20)
    }

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
    }

    private let reportButton = Button.Normal(size: .h48, text: "신고하기").then {
        $0.isEnabled = false
    }

    private let closeButton = UIButton().then {
        $0.setImage(Icons.close.image.resizeImage(scaledTo: 16).withTintColor(.white), for: .normal)
        $0.backgroundColor = Colors.gray40.color
        $0.layer.cornerRadius = 12
    }

    private lazy var dataSource = ReportPollDataSource(viewModel: viewModel, collectionView: collectionView)

    private let viewModel: ReportPollViewModel

    init(_ viewModel: ReportPollViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.input.firstLoad.send()
    }

    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubViews([
            backgroundButton,
            containerView,
        ])

        containerView.addSubViews([
            titleLabel,
            collectionView,
            reportButton,
            closeButton
        ])

        backgroundButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }

        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(244)
        }

        reportButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        addKeyboardObservers()
    }

    override func bindEvent() {
        super.bindEvent()

        closeButton
            .controlPublisher(for: .touchUpInside)
            .merge(
                with: backgroundButton
                    .controlPublisher(for: .touchUpInside)
            )
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)

        // Input
        reportButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReportButton)
            .store(in: &cancellables)

        // Output
        viewModel.output.dataSource
            .withUnretained(self)
            .main
            .sink { owner, sectionItems in
                owner.dataSource.reloadData(sectionItems: sectionItems) {
                    owner.collectionView.snp.updateConstraints {
                        $0.height.equalTo(Layout.listHeight(hasReasonDetail: sectionItems.contains(where: {
                            $0 == .reasonDetail
                        })))
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.output.isEnabledButton
            .withUnretained(self)
            .main
            .sink { owner, isEnabledButton in
                owner.reportButton.isEnabled = isEnabledButton
            }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink {
                ToastManager.shared.show(message: $0)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .back:
                    owner.back()
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: ReportPollViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }

    private func back() {
        dismiss(animated: true)
    }

    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6

        return layout
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

        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform(
                translationX: 0,
                y: -keyboardFrame.cgRectValue.height + bottomPadding
            )
        }
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
    }
}

extension ReportPollViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        viewModel.input.didSelectItem.send(item)
    }
}

extension ReportPollViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .reason:
            return CGSize(width: collectionView.frame.width, height: ReportPollReasonCell.Layout.height)
        case .reasonDetail:
            return CGSize(width: collectionView.frame.width, height: ReportPollReasonDetailCell.Layout.height)
        default:
            return .zero
        }
    }
}
