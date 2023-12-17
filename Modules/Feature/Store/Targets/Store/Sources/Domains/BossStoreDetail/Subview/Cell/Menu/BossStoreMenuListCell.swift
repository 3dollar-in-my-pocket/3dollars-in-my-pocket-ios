import UIKit
import Common
import DesignSystem
import Model

final class BossStoreMenuListCell: BaseCollectionViewCell {
    enum Layout {
        static func height(viewModel: BossStoreMenuListCellViewModel) -> CGFloat {
            var height: CGFloat = 32
            let itemCount = CGFloat(viewModel.output.menuList.value.count)
            height += itemCount * BossStoreMenuItemCell.Layout.height
            height += CGFloat(itemCount - 1) * 16
            if viewModel.output.moreItemCount.value != 0 {
                height += BossStoreMenuMoreCell.Layout.height
                height += 16
            }
            return height
        }
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.isScrollEnabled = false
        $0.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        $0.register([
            BossStoreMenuItemCell.self,
            BossStoreMenuMoreCell.self
        ])
    }
    
    private var viewModel: BossStoreMenuListCellViewModel?
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        contentView.addSubViews([containerView])
        
        containerView.addSubViews([collectionView])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ viewModel: BossStoreMenuListCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.menuList
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset.bottom = 16
        return layout
    }
}

extension BossStoreMenuListCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel?.output.moreItemCount.value != 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: viewModel?.output.menuList.value.count ?? 0
        case 1: 1
        default: 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell: BossStoreMenuItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            if let menu = viewModel?.output.menuList.value[safe: indexPath.item] {
                cell.bind(menu: menu)
            }
            
            return cell
        case 1:
            let cell: BossStoreMenuMoreCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
            cell.bind(count: viewModel?.output.moreItemCount.value ?? 0)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension BossStoreMenuListCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.frame.width, height: BossStoreMenuItemCell.Layout.height)
        case 1:
            return CGSize(width: collectionView.frame.width, height: BossStoreMenuMoreCell.Layout.height)
        default:
            return .zero
        }
    }
}

extension BossStoreMenuListCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1: viewModel?.input.didTapMore.send()
        default: break
        }
    }
}
