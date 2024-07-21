import UIKit

import DesignSystem
import Then
import Common
import Log

public final class BossStorePostListViewController: BaseViewController {
    private let backButton = UIButton().then {
        $0.setImage(Icons.arrowLeft.image.withTintColor(Colors.gray100.color), for: .normal)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.contentInset = .init(top: 0, left: 0, bottom: 24, right: 0)
        $0.dataSource = self
        $0.delegate = self
        $0.register([BossStorePostCell.self])
    }
    
    private let viewModel: BossStorePostListViewModel
    
    init(viewModel: BossStorePostListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
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
        view.backgroundColor = Colors.systemWhite.color
        
        view.addSubViews([
            backButton,
            collectionView
        ])
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    public override func bindEvent() {
        super.bindEvent()
        
        backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override public func bindViewModelInput() {
        super.bindViewModelInput()
    }
    
    public override func bindViewModelOutput() {
        super.bindViewModelOutput()
        
        viewModel.output.sectionItems
            .main
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
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
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        return layout
    }
}

extension BossStorePostListViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.sectionItems.value.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellViewModel = viewModel.output.sectionItems.value[safe: indexPath.item] else { return UICollectionViewCell() }
        
        let cell: BossStorePostCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(cellViewModel)
        return cell
    }
}

extension BossStorePostListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}

extension BossStorePostListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellViewModel = viewModel.output.sectionItems.value[safe: indexPath.item] else { return .zero }
        
        return CGSize(width: collectionView.frame.width, height: BossStorePostCell.Layout.height(viewModel: cellViewModel, width: collectionView.frame.width))
    }
}
