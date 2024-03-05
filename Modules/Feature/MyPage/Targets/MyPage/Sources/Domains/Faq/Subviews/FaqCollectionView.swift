import UIKit

import Common
import DesignSystem
import Model

final class FaqCollectionView: UICollectionView {
    enum Layout {
        static let minimumLineSpacing: CGFloat = 12
        static let minimumInteritemSpacing: CGFloat = 12
    }
    
    private var faqSections: [[FaqResponse]] = []
    
    init() {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = FaqCollectionHeaderView.Layout.size
        layout.minimumLineSpacing = Layout.minimumLineSpacing
        layout.minimumInteritemSpacing = Layout.minimumInteritemSpacing
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ sections: [[FaqResponse]]) {
        faqSections = sections
        reloadData()
    }
    
    private func setup() {
        backgroundColor = .clear
        register([
            FaqCollectionCell.self
        ])
        registerSectionHeader([
            FaqCollectionHeaderView.self
        ])
        
        dataSource = self
        delegate = self
    }
}

extension FaqCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return faqSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = faqSections[safe: section] else { return 0 }
        
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let faq = faqSections[safe: indexPath.section]?[safe: indexPath.item] else { return BaseCollectionViewCell() }
        
        let cell: FaqCollectionCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        cell.bind(faq: faq)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let faq = faqSections[safe: indexPath.section]?[safe: indexPath.item]
        let headerView: FaqCollectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
        
        headerView.bind(faq)
        return headerView
    }
}

extension FaqCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let faq = faqSections[safe: indexPath.section]?[safe: indexPath.item] else { return .zero }
        
        return FaqCollectionCell.Layout.calculateSize(faq: faq)
    }
}
