import UIKit

import DesignSystem

final class PollDetailViewController: BaseViewController {

    private lazy var navigationBar = CommunityNavigationBar(rightButtons: [reportButton])

    private let reportButton = UIButton().then {
        $0.setImage(
            Icons.deletion.image
                .resizeImage(scaledTo: 24)
                .withTintColor(Colors.mainRed.color),
            for: .normal
        )
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
    }

    private lazy var dataSource = PollDetailDataSource(collectionView: collectionView)
 
    init() {
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func bindEvent() {
        super.bindEvent()

        reportButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                let vc = ReportPollViewController()
                owner.present(vc, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray0.color

        view.addSubViews([
            navigationBar,
            collectionView
        ])

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        dataSource.reloadData()
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
}

// MARK: TextField
