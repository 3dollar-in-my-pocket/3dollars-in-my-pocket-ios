import Foundation
import UIKit
import Combine
import Then
import Common

/// 커뮤니티/구 선택 팝업
final class CommunityPopularStoreNeighborhoodsViewController: BaseViewController {

    enum Layout {

    }

    private let backgroundButton = UIButton()

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private let titleLabel = UILabel().then {
        $0.text = "어디 인기 가게를 볼까요?"
        $0.textColor = Colors.gray100.color
        $0.font = Fonts.semiBold.font(size: 20)
    }

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }

    private let closeButton = UIButton().then {
        $0.setImage(Icons.close.image.resizeImage(scaledTo: 16).withTintColor(.white), for: .normal)
        $0.backgroundColor = Colors.gray40.color
        $0.layer.cornerRadius = 12
    }

    private lazy var dataSource = CommunityPopularStoreNeighborhoodsDataSource(collectionView: collectionView)
    private let viewModel: CommunityPopularStoreNeighborhoodsViewModel

    init(viewModel: CommunityPopularStoreNeighborhoodsViewModel = .init()) {
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

    func setupUI() {
        view.addSubViews([
            backgroundButton,
            containerView,
        ])

        containerView.addSubViews([
            titleLabel,
            collectionView,
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
            $0.height.equalTo(600)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        view.backgroundColor = .clear

    }

    override func bindEvent() {
        super.bindEvent()

        // UI
        closeButton
            .controlPublisher(for: .touchUpInside)
            .merge(
                with: backgroundButton
                    .controlPublisher(for: .touchUpInside)
            )
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)

        // Output
        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reloadData(sections)
            }
            .store(in: &cancellables)
    }

    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6

        return layout
    }
}

extension CommunityPopularStoreNeighborhoodsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true)
    }
}

extension CommunityPopularStoreNeighborhoodsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CommunityPopularStoreNeighborhoodsCell.Layout.height)
    }
}
