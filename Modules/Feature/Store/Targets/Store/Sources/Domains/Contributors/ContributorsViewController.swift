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
    private let sduCollectionView = SDUCollectionView()
    private lazy var dataSource = SDUDataSource(collectionView: sduCollectionView.collectionView)

    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        label.text = "정보 기여자 목록"
        label.textAlignment = .center
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.resizeImage(scaledTo: 24).withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Colors.gray100.color
        return button
    }()

    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        return view
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("나도 수정하기", for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 16)
        button.setTitleColor(Colors.gray100.color, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray30.color.cgColor
        return button
    }()

    public init(viewModel: ContributorsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupCollectionView()

        viewModel.input.load.send(())
    }

    private func setupCollectionView() {
        sduCollectionView.collectionView.registerSectionHeader([ContributorsSectionHeaderView.self])
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let headerView: ContributorsSectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: kind, indexPath: indexPath)

            return headerView
        }

        sduCollectionView.setLayout(createLayout())
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray0.color
        view.addSubview(topContainerView)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(closeButton)
        view.addSubview(sduCollectionView)
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(editButton)

        topContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(-60)
            $0.bottom.equalToSuperview().offset(-16)
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
            $0.centerY.equalTo(titleLabel)
        }

        sduCollectionView.snp.makeConstraints {
            $0.top.equalTo(topContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(editButton.snp.top)
        }

        bottomContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-72)
        }

        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(48)
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
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(64)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    public override func bindViewModelInput() {
        editButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)

        closeButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapClose)
            .store(in: &cancellables)
    }

    public override func bindViewModelOutput() {
        viewModel.output.items
            .main
            .withUnretained(self)
            .sink { (owner, items) in
                owner.dataSource.reload(items)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner, route) in
                owner.handleRoute(route)
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

        case .dismissAndEdit:
            dismiss(animated: true) { [weak self] in
                self?.viewModel.onEditRequested()
            }

        case .pushEditStore(let viewModel):
            break

        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
