import UIKit

import Common
import DesignSystem
import SnapKit
import Then
import Model

final class MyPageStoreListCell: BaseCollectionViewCell {
    enum Layout {
        static func height(_ items: [MyPageStore]) -> CGFloat {
            items.map { MyPageStoreItemCell.Layout.size($0).height }.max() ?? MyPageStoreItemCell.Layout.defaultHeight
        }
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = .fast
        $0.register([MyPageStoreItemCell.self])
        $0.dataSource = self
        $0.delegate = self
    }
    
    private var viewModel: MyPageStoreListCellViewModel?
    private var data: [MyPageStore] = []
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            collectionView
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ viewModel: MyPageStoreListCellViewModel) {
        self.viewModel = viewModel
        self.data = viewModel.output.items
        
        collectionView.reloadData()
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        return layout
    }
}

extension MyPageStoreListCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = data[safe: indexPath.item] else { return UICollectionViewCell() }
        
        let cell: MyPageStoreItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(item: item)
        return cell
    }
}

extension MyPageStoreListCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didSelect.send(indexPath.item)
    }
}

extension MyPageStoreListCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = data[safe: indexPath.item] else { return .zero }
        
        return MyPageStoreItemCell.Layout.size(item)
    }
}
