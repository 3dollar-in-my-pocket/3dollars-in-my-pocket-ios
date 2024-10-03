import UIKit

import Model

final class WriteDetailDataSource: UICollectionViewDiffableDataSource<WriteDetailSection, WriteDetailSectionItem> {
    let viewModel: WriteDetailViewModel
    
    init(collectionView: UICollectionView, viewModel: WriteDetailViewModel) {
        self.viewModel = viewModel
        
        collectionView.register([
            WriteDetailMapCell.self,
            WriteDetailAddressCell.self,
            WriteDetailNameCell.self,
            WriteDetailTypeCell.self,
            WriteDetailPaymentCell.self,
            WriteDetailDayCell.self,
            WriteDetailTimeCell.self,
            WriteDetailCategoryCollectionCell.self,
            WriteDetailMenuGroupCell.self
        ])
        collectionView.registerSectionHeader([
            WriteDetailHeaderView.self,
            WriteDetailCategoryHeaderView.self
        ])
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .map(let location):
                let cell: WriteDetailMapCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(location: location)
                cell.zoomButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.tapFullMap)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .address(let address):
                let cell: WriteDetailAddressCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(address: address)
                cell.editAddressButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.tapEditLocation)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .name(let name):
                let cell: WriteDetailNameCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(name: name)
                cell.nameField.publisher(for: \.text)
                    .map { $0 ?? "" }
                    .subscribe(viewModel.input.storeName)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .storeType(let salesType):
                let cell: WriteDetailTypeCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(salesType: salesType)
                cell.tapPublisher
                    .subscribe(viewModel.input.tapSalesType)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .paymentMethod(let paymentMethods):
                let cell: WriteDetailPaymentCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(paymentMethods: paymentMethods)
                cell.tapPublisher
                    .subscribe(viewModel.input.tapPaymentMethod)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .appearanceDay(let appearanceDays):
                let cell: WriteDetailDayCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(appearanceDays)
                cell.tapPublisher
                    .subscribe(viewModel.input.tapDay)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .time(let viewModel):
                let cell: WriteDetailTimeCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(viewModel: viewModel)
                return cell
                
            case .categoryCollection(let categories):
                let cell: WriteDetailCategoryCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(categories: categories)
                cell.bindViewModel(viewModel)
                
                return cell
                
            case .menuGroup(let cellViewModel):
                let cell: WriteDetailMenuGroupCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(viewModel: cellViewModel)
                cell.closeButton.controlPublisher(for: .touchUpInside)
                    .map { _ in indexPath.row - 1 }
                    .subscribe(viewModel.input.tapDeleteCategory)
                    .store(in: &cell.cancellables)
                
                return cell
            }
        }
        
        self.supplementaryViewProvider = { [weak self] collectionView, type, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }
            
            switch section.type.headerType {
            case .none:
                return nil
                
            case .normal, .multi, .option:
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(WriteDetailHeaderView.self)",
                    for: indexPath
                ) as? WriteDetailHeaderView
                
                headerView?.bind(type: section.type.headerType)
                return headerView
                
            case .category:
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(WriteDetailCategoryHeaderView.self)",
                    for: indexPath
                ) as? WriteDetailCategoryHeaderView
                
                if let headerView = headerView {
                    headerView.deleteButton
                        .controlPublisher(for: .touchUpInside)
                        .mapVoid
                        .subscribe(viewModel.input.deleteAllCategories)
                        .store(in: &headerView.cancellables)
                }
                
                return headerView
            }
        }
        
        collectionView.delegate = self
    }
}

struct WriteDetailSection: Hashable {
    enum SectionType: Hashable {
        case map
        case address
        case name
        case storeType
        case paymentMethod
        case appearanceDay
        case time
        case category
        
        var headerType: WriteDetailHeaderView.HeaderType {
            switch self {
            case .map:
                return .none
                
            case .address:
                return .normal(title: Strings.writeDetailHeaderLocation)
                
            case .name:
                return .normal(title: Strings.writeDetailHeaderName)
                
            case .storeType:
                return .option(title: Strings.writeDetailHeaderStoreType)
                
            case .paymentMethod:
                return .multi(title: Strings.writeDetailHeaderPaymentType)
                
            case .appearanceDay:
                return .multi(title: Strings.writeDetailHeaderDay)
                
            case .time:
                return .option(title: "출몰 시간대")
                
            case .category:
                return .category
            }
        }
    }
    
    let type: SectionType
    var items: [WriteDetailSectionItem]
}

enum WriteDetailSectionItem: Hashable {
    case map(LocationResponse)
    case address(String?)
    case name(String)
    case storeType(SalesType?)
    case paymentMethod([PaymentMethod])
    case appearanceDay([AppearanceDay])
    case time(WriteDetailTimeCellViewModel)
    case categoryCollection([Model.PlatformStoreCategory?])
    case menuGroup(WriteDetailMenuGroupViewModel)
    
    var size: CGSize {
        switch self {
        case .map:
            return WriteDetailMapCell.Layout.size
            
        case .address:
            return WriteDetailAddressCell.Layout.size
            
        case .name:
            return WriteDetailNameCell.Layout.size
            
        case .storeType:
            return WriteDetailTypeCell.Layout.size
            
        case .paymentMethod:
            return WriteDetailPaymentCell.Layout.size
            
        case .appearanceDay:
            return WriteDetailDayCell.Layout.size
            
        case .time:
            return WriteDetailTimeCell.Layout.size
            
        case .categoryCollection(let categories):
            return WriteDetailCategoryCollectionCell.Layout.size(count: categories.count)
            
        case .menuGroup(let viewModel):
            return WriteDetailMenuGroupCell.Layout.size(count: viewModel.output.menus.count)
        }
    }
}


extension WriteDetailDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = itemIdentifier(for: indexPath) else { return .zero }
        
        return item.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let section = self.sectionIdentifier(section: section) else { return .zero }
        
        switch section.type.headerType {
        case .none:
            return .zero
            
        case .option, .normal, .multi:
            return WriteDetailHeaderView.Layout.size
            
        case .category:
            return WriteDetailCategoryHeaderView.Layout.size
        }
    }
}
