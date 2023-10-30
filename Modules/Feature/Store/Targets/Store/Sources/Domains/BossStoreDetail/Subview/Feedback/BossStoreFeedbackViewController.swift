import Foundation
import UIKit
import Combine

import Then
import Common
import DesignSystem

final class BossStoreFeedbackViewController: BaseViewController {

    enum Layout {

    }

    private let closeButton = UIButton().then {
        $0.setImage(
            Icons.close.image
                .resizeImage(scaledTo: 24)
                .withTintColor(Colors.gray100.color),
            for: .normal
        )
    }

    private let titleLabel = UILabel().then {
        $0.text = "리뷰 남기기"
        $0.textColor = Colors.gray100.color
        $0.font = Fonts.medium.font(size: 16)
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

    private let sendFeedbackButton = UIButton().then {
        $0.isEnabled = false
        $0.backgroundColor = Colors.mainPink.color
        $0.setTitle("리뷰 남기기 완료!", for: .normal)
        $0.titleLabel?.font = Fonts.bold.font(size: 16)
        $0.setTitleColor(.white, for: .normal)
    }

    private let bottomBackgroundView = UIView().then {
        $0.backgroundColor = Colors.mainPink.color
    }

    private lazy var dataSource = BossStoreFeedbackDataSource(collectionView: collectionView)

    private let viewModel: BossStoreFeedbackViewModel

    init(_ viewModel: BossStoreFeedbackViewModel) {
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
        view.backgroundColor = .white

        view.addSubViews([
            closeButton,
            titleLabel,
            collectionView,
            sendFeedbackButton,
            bottomBackgroundView
        ])

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(sendFeedbackButton.snp.top)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(closeButton)
            $0.centerX.equalToSuperview()
        }

        sendFeedbackButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomBackgroundView.snp.top)
            $0.height.equalTo(64)
        }

        bottomBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    override func bindEvent() {
        super.bindEvent()

        // Input
        closeButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)

        sendFeedbackButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSendFeedbackButton)
            .store(in: &cancellables)

        // Output
        viewModel.output.dataSource
            .withUnretained(self)
            .main
            .sink { owner, sectionItems in
                owner.dataSource.reloadData(sectionItems: sectionItems)
            }
            .store(in: &cancellables)

        viewModel.output.isEnabledButton
            .withUnretained(self)
            .main
            .sink { owner, isEnabledButton in
                owner.setEnableSendFeedbackButton(isEnable: isEnabledButton)
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
    }

    private func back() {
        dismiss(animated: true)
    }

    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        return layout
    }

    private func setEnableSendFeedbackButton(isEnable: Bool) {
        self.sendFeedbackButton.isEnabled = isEnable
        if isEnable {
            sendFeedbackButton.backgroundColor = Colors.mainPink.color
            bottomBackgroundView.backgroundColor = Colors.mainPink.color
        } else {
            sendFeedbackButton.backgroundColor = Colors.gray30.color
            bottomBackgroundView.backgroundColor = Colors.gray30.color
        }
    }
}

extension BossStoreFeedbackViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        viewModel.input.didSelectItem.send(item)
    }
}

extension BossStoreFeedbackViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feedback:
            return CGSize(width: collectionView.frame.width, height: BossStoreFeedbackItemCell.Layout.height)
        case .none:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: BossStoreFeedbackHeaderCell.Layout.height)
    }
}
