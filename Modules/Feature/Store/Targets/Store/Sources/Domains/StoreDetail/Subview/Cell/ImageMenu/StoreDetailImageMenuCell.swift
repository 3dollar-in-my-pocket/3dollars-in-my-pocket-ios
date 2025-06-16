import UIKit
import Common
import DesignSystem
import Model

final class StoreDetailImageMenuCell: BaseCollectionViewCell {
    enum Layout {
        static let topPadding: CGFloat = 12
        static let emptyCellHeight: CGFloat = 78
        
        static func height(viewModel: StoreDetailImageMenuCellViewModel) -> CGFloat {
            var height: CGFloat = 32
            let itemCount = CGFloat(viewModel.output.menus.value.count)
            height += itemCount * StoreDetailImageMenuItemCell.Layout.height
            height += CGFloat(itemCount - 1) * 16
            if viewModel.output.moreItemCount.value != 0 {
                height += StoreDetailImageMenuMoreCell.Layout.height
                height += 16
            }
            return height
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        collectionView.register([
            StoreDetailImageMenuItemCell.self,
            StoreDetailImageMenuMoreCell.self
        ])
        return collectionView
    }()
    
    private var viewModel: StoreDetailImageMenuCellViewModel?
    
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
    
    func bind(viewModel: StoreDetailImageMenuCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.menus
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

extension StoreDetailImageMenuCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel?.output.moreItemCount.value != 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: viewModel?.output.menus.value.count ?? 0
        case 1: 1
        default: 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell: StoreDetailImageMenuItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            if let menu = viewModel?.output.menus.value[safe: indexPath.item] {
                cell.bind(menu: menu)
            }
            
            return cell
        case 1:
            let cell: StoreDetailImageMenuMoreCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(count: viewModel?.output.moreItemCount.value ?? 0)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension StoreDetailImageMenuCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.frame.width, height: StoreDetailImageMenuItemCell.Layout.height)
        case 1:
            return CGSize(width: collectionView.frame.width, height: StoreDetailImageMenuMoreCell.Layout.height)
        default:
            return .zero
        }
    }
}

extension StoreDetailImageMenuCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break
        case 1: viewModel?.input.didTapMore.send()
        default: break
        }
    }
}
