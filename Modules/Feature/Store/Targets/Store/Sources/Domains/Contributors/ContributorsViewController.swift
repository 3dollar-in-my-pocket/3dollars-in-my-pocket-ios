import UIKit
import Combine

import Common
import DependencyInjection
import DesignSystem
import Model
import SDU
import SnapKit
import WriteInterface

public final class ContributorsViewController: BaseViewController {
    private let viewModel: ContributorsViewModel
    private let sduView = SDUCollectionView()
    private lazy var dataSource = SDUDataSource(collectionView: sduView.collectionView)

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "함께 만든 가게 정보"
        label.font = Fonts.semiBold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("나도 수정하기", for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 16)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.mainPink.color
        button.layer.cornerRadius = 8
        return button
    }()

    public static func instance(config: ContributorsViewModel.Config) -> ContributorsViewController {
        return ContributorsViewController(viewModel: ContributorsViewModel(config: config))
    }

    public init(viewModel: ContributorsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupUI()
        sduView.setLayout(createLayout())

        viewModel.input.load.send(())
    }

    private func setupNavigationBar() {
        title = "기여자 목록"

        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: nil,
            action: nil
        )
        closeButton.tintColor = Colors.gray100.color
        navigationItem.leftBarButtonItem = closeButton

        closeButton.tapPublisher
            .mapVoid
            .subscribe(viewModel.input.didTapClose)
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubview(headerLabel)
        view.addSubview(sduView)
        view.addSubview(editButton)

        headerLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        sduView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(editButton.snp.top).offset(-16)
        }

        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(56)
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        ))

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 16, leading: 20, bottom: 20, trailing: 20)

        return UICollectionViewCompositionalLayout(section: section)
    }

    public override func bindViewModelInput() {
        editButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)
    }

    public override func bindViewModelOutput() {
        viewModel.output.items
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner, items) in
                owner.dataSource.reload(items)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner, route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)

        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner, error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Route
extension ContributorsViewController {
    private func handleRoute(_ route: ContributorsViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)

        case .pushEditStore(let viewModel):
            pushEditStore(viewModel)
        }
    }

    private func pushEditStore(_ viewModel: EditStoreViewModelInterface) {
        let writeInterface = DIContainer.shared.container.resolve(WriteInterface.self)!
        let writeVC = writeInterface.createEditStoreViewController(viewModel: viewModel)
        navigationController?.pushViewController(writeVC, animated: true)
    }
}
