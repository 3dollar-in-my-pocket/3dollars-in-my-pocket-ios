import UIKit

import Common
import DesignSystem
import Model

final class WriteDetailCategoryCollectionCell: BaseCollectionViewCell {
    enum Layout {
        static func size(count: Int) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.width, height: height(count: count) + 24 + 12)
        }
        static func height(count: Int) -> CGFloat {
            let numberOfRow = numberOfRow(count: count)
            let space = lineSpace * (numberOfRow - 1)
            
            return WriteDetailCollectionItemCell.Layout.size.height * numberOfRow + space
        }
        static func numberOfRow(count: Int) -> CGFloat {
            if count <= numberOfItemInRow {
                return 1
            } else {
                return CGFloat(count / numberOfItemInRow) + 1
            }
        }
        static let lineSpace: CGFloat = 16
        static let itemSpace: CGFloat = 10
        static let numberOfItemInRow = 5
    }
    
    private var viewModel: WriteDetailViewModel?
    private var categories: [Model.PlatformStoreCategory?] = []
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = Colors.systemWhite.color
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.contentInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.register([WriteDetailCollectionItemCell.self])
    }
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        contentView.addSubview(collectionView)
           
        collectionView.dataSource = self
    }
    
    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func bind(categories: [Model.PlatformStoreCategory?]) {
        self.categories = categories
        collectionView.reloadData()
    }
    
    func bindViewModel(_ viewModel: WriteDetailViewModel) {
        self.viewModel = viewModel
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.itemSize = WriteDetailCollectionItemCell.Layout.size
        layout.minimumLineSpacing = Layout.lineSpace
        layout.minimumInteritemSpacing = Layout.itemSpace
        
        return layout
    }
}

extension WriteDetailCategoryCollectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let category = categories[safe: indexPath.row] else { return UICollectionViewCell() }
        let cell: WriteDetailCollectionItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        cell.bind(category: category)
        
        if let viewModel = viewModel {
            cell.closeButton
                .controlPublisher(for: .touchUpInside)
                .map { _ in indexPath.row - 1 }
                .subscribe(viewModel.input.tapDeleteCategory)
                .store(in: &cancellables)
            
            if indexPath.row == 0 {
                cell.categoryButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.tapAddCategory)
                    .store(in: &cell.cancellables)
            }
        }
        
        return cell
    }
}
