import UIKit

import SnapKit

import Model
import DesignSystem
import Common
import StoreInterface
import Log

/// 방문 인증 내역
public final class VisitStoreListViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("편집", for: .normal)
        button.setTitle("완료", for: .selected)
        button.setTitle("완료", for: [.selected, .highlighted])
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 14)
        button.isHidden = true
        return button
    }()

    private lazy var myPageNavigationBar = MyPageNavigationBar(title: "방문 인증 내역", rightButtons: [editButton])
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = Colors.gray100.color
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 24, right: 20)
        collectionView.delegate = self
        return collectionView
    }()
    
    private let emptyView: MyPageEmptyView = {
        let emptyView = MyPageEmptyView()
        emptyView.isHidden = true
        emptyView.bind(title: "방문 인증 내역이 없어요!", description: "방문하고 가게 정확도를 높혀봐요")
        return emptyView
    }()
    
    private lazy var dataSource = VisitStoreListDataSource(collectionView: collectionView) { [weak self] item in
        self?.viewModel.input.didTapDelete.send(item)
    }
    
    private let viewModel: VisitStoreListViewModel
    
    init(viewModel: VisitStoreListViewModel = VisitStoreListViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.loadTrigger.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.gray100.color
        
        view.addSubViews([
            myPageNavigationBar,
            collectionView,
            emptyView
        ])
        
        myPageNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(MyPageNavigationBar.Layout.height)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(self.myPageNavigationBar.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    public override func bindEvent() {
        super.bindEvent()
        
        myPageNavigationBar.backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

        editButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        super.bindViewModelOutput()
        
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { owner, error in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.emptyView.isHidden = sections.isNotEmpty
                owner.editButton.isHidden = sections.isEmpty
                owner.dataSource.reload(sections)
            }
            .store(in: &cancellables)

        viewModel.output.isEditing
            .main
            .withUnretained(self)
            .sink { owner, isEditing in
                owner.editButton.isSelected = isEditing
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .storeDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                case .bossStoreDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                case .presentDeleteAlert(let item):
                    owner.presentDeleteAlert(item)
                }
            }
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = .init(top: 0, left: 0, bottom: 40, right: 0)
        return layout
    }
    
    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailFullScreenViewController(storeId: storeId)

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentDeleteAlert(_ item: MyVisitStore) {
        AlertUtils.showWithCancel(
            viewController: self,
            message: "방문 인증을 삭제할까요?",
            okButtonTitle: "삭제"
        ) { [weak self] in
            self?.viewModel.input.didConfirmDelete.send(item)
        }
    }

    private func pushStoreDetail(storeId: String) {
        guard let storeId = Int(storeId) else { return }
        pushStoreDetail(storeId: storeId)
    }
}

extension VisitStoreListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelectItem.send(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplaytCell.send(indexPath.section)
    }
}

extension VisitStoreListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: VisitStoreItemCell.Layout.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: VisitStoreHeaderView.Layout.height)
    }
}
