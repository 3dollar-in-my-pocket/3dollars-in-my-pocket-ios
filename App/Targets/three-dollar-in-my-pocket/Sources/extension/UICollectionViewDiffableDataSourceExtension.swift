import UIKit

extension UICollectionViewDiffableDataSource {
    func sectionIdentifier(section: Int) -> SectionIdentifierType? {
        if #available(iOS 15.0, *) {
            return sectionIdentifier(for: section)
        } else {
            return snapshot().sectionIdentifiers[safe: section]
        }
    }
    
    subscript(indexPath: IndexPath) -> ItemIdentifierType? {
        if #available(iOS 15.0, *) {
            return itemIdentifier(for: indexPath)
        } else {
            let snapshot = self.snapshot()
            if let section = snapshot.sectionIdentifiers[safe: indexPath.section] {
                return self.snapshot().itemIdentifiers(inSection: section)[safe: indexPath.item]
            }
            return nil
        }
    }
}
