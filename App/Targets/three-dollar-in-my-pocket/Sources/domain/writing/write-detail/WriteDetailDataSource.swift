import UIKit

final class WriteDetailDataSource: UICollectionViewDiffableDataSource<WriteDetailSection, WriteDetailSectionItem> {
    init(collectionView: UICollectionView) {
        collectionView.register([
            WriteDetailLocationCell.self,
            WriteDetailNameCell.self,
            WriteDetailTypeCell.self,
            WriteDetailPaymentCell.self
        ])
        collectionView.registerSectionHeader([WriteDetailHeaderView.self])
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .location:
                let cell: WriteDetailLocationCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
                
            case .name:
                let cell: WriteDetailNameCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
                
            case .storeType:
                let cell: WriteDetailTypeCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
                
            case .payment:
                let cell: WriteDetailPaymentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
            }
        }
        
        supplementaryViewProvider = { collectionView, type, indexPath in
            guard let section = self.sectionIdentifier(section: indexPath.section),
                  let headerView = collectionView.dequeueReusableSupplementaryView(
                      ofKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: "\(WriteDetailHeaderView.self)",
                      for: indexPath
                  ) as? WriteDetailHeaderView else { return nil }
            
            headerView.bind(type: section.type.headerType)
            return headerView
        }
        
        collectionView.delegate = self
    }
}

struct WriteDetailSection: Hashable {
    enum SectionType: Hashable {
    //    case map
        case location
        case name
        case storeType
        case payment
        
        var headerType: WriteDetailHeaderView.HeaderType {
            switch self {
            case .location:
                return .normal(title: ThreeDollarInMyPocketStrings.writeDetailHeaderLocation)
                
            case .name:
                return .normal(title: ThreeDollarInMyPocketStrings.writeDetailHeaderName)
                
            case .storeType:
                return .option(title: ThreeDollarInMyPocketStrings.writeDetailHeaderStoreType)
                
            case .payment:
                return .multi(title: ThreeDollarInMyPocketStrings.writeDetailHeaderPaymentType)
            }
        }
    }
    
    let type: SectionType
    var items: [WriteDetailSectionItem]
}

enum WriteDetailSectionItem: Hashable {
//    case map
    case location
    case name
    case storeType
    case payment
    
    var size: CGSize {
        switch self {
        case .location:
            return WriteDetailLocationCell.Layout.size
            
        case .name:
            return WriteDetailNameCell.Layout.size
            
        case .storeType:
            return WriteDetailTypeCell.Layout.size
            
        case .payment:
            return WriteDetailPaymentCell.Layout.size
        }
    }
}


extension WriteDetailDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = itemIdentifier(for: indexPath) else { return .zero }
        
        return item.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return WriteDetailHeaderView.Layout.size
    }
}
