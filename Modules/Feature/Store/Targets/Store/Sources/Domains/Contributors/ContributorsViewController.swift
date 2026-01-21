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

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "함께 만든 가게 정보"
        label.font = Fonts.semiBold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
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
        sduCollectionView.setLayout(createLayout())

        viewModel.input.load.send(())
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray0.color
        view.addSubview(topContainerView)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(closeButton)
        view.addSubview(headerLabel)
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

        headerLabel.snp.makeConstraints {
            $0.top.equalTo(topContainerView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
        }

        sduCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(editButton.snp.top).offset(-16)
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
        section.contentInsets = .init(top: 16, leading: 20, bottom: 20, trailing: 20)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    public override func bindEvent() {
        closeButton.tapPublisher
            .throttleClick()
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
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
