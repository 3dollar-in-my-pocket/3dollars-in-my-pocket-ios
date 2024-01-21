import UIKit
import Combine

import Common
import Model
import DesignSystem

final class FaqCategoryView: BaseView {
    enum Layout {
        static func calculateHeight(categories: [FaqCategoryResponse]) -> CGFloat {
            var row = 1
            var totalWidth: CGFloat = 0
            for category in categories {
                let width = FaqCategoryCell.Layout.calculateSize(category: category).width
                totalWidth += width + 8
                
                if totalWidth >= (UIUtils.windowBounds.width - 88) {
                    row += 1
                    totalWidth = 0
                }
            }
            
            let height = (row * 34) + ((row - 1) * 8)
            return CGFloat(height)
        }
    }
    
    let didSelectCategory = PassthroughSubject<Int, Never>()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var datasource: [FaqCategoryResponse] = []
    
    override func setup() {
        addSubViews([
            collectionView
        ])
        
        collectionView.register([
            FaqCategoryCell.self
        ])
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(categories: [FaqCategoryResponse]) {
        datasource = categories
        collectionView.reloadData()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout =  UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        return layout
    }
}

extension FaqCategoryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let category = datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: FaqCategoryCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        cell.bind(category: category)
        return cell
    }
}

extension FaqCategoryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectCategory.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let category = datasource[safe: indexPath.item] else { return .zero }
        
        return FaqCategoryCell.Layout.calculateSize(category: category)
    }
}
