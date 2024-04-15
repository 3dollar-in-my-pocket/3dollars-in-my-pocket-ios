import UIKit

import Common
import DesignSystem
import Model

final class CommunityPopularStoreNeighborhoodsContentViewController: BaseViewController {
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private var viewModel: CommunityPopularStoreNeighborhoodsContentViewModel?
    private lazy var dataSource = CommunityPopularStoreNeighborhoodsContentDataSource(collectionView: collectionView)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bind(_ viewModel: CommunityPopularStoreNeighborhoodsContentViewModel) {
        self.viewModel = viewModel
        viewModel.output.datasource
            .main
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreNeighborhoodsContentViewController, sections: [CommunityPopularStoreNeighborhoodsSection]) in
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

extension CommunityPopularStoreNeighborhoodsContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didSelectItem.send(indexPath.item)
    }
}

extension CommunityPopularStoreNeighborhoodsContentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CommunityPopularStoreNeighborhoodsCell.Layout.height)
    }
}
