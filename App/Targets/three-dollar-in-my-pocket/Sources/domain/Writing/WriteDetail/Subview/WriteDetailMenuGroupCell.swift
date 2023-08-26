import UIKit

import DesignSystem

final class WriteDetailMenuGroupCell: BaseCollectionViewCell {
    enum Layout {
        static func size(count: Int) -> CGSize {
            let width = UIScreen.main.bounds.width
            let itemGroupHeight = itemGroupHeight(count: count)
            
            return CGSize(width: width, height: itemGroupHeight + topOffset + 64)
        }
        static let topOffset: CGFloat = 12
        static func itemGroupHeight(count: Int) -> CGFloat {
            let itemHeight = WriteDetailMenuItemCell.Layout.size.height * CGFloat(count)
            let space = count - 1 > 0 ? space * CGFloat(count - 1) : 0
            
            return itemHeight + space + topOffset
        }
        static let space: CGFloat = 8
    }
    
    private var viewModel: WriteDetailMenuGroupViewModel?
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.systemWhite.color
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    private let categoryImageView = UIImageView()
    
    private let categoryNameLabel = UILabel().then {
        $0.font = Fonts.Pretendard.bold.font(size: 14)
        $0.textColor = Colors.gray90.color
    }
    
    let closeButton = UIButton().then {
        $0.backgroundColor = Colors.mainRed.color
        $0.layer.cornerRadius = 10
        $0.setImage(Icons.close.image.withTintColor(Colors.gray0.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    lazy var menuCollectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.register([WriteDetailMenuItemCell.self])
        $0.dataSource = self
    }
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        containerView.addSubViews([
            categoryImageView,
            categoryNameLabel,
            closeButton,
            menuCollectionView
        ])
        contentView.addSubview(containerView)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Layout.topOffset)
        }
        
        categoryImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.width.height.equalTo(24)
        }
        
        categoryNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryImageView)
            $0.left.equalTo(categoryImageView.snp.right).offset(4)
        }
        
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-12)
            $0.centerY.equalTo(categoryImageView)
            $0.width.height.equalTo(20)
        }
        
        menuCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-12)
            $0.top.equalTo(categoryImageView.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(viewModel: WriteDetailMenuGroupViewModel) {
        self.viewModel = viewModel
        
        categoryImageView.setImage(urlString: viewModel.output.category.imageUrl)
        categoryNameLabel.text = viewModel.output.category.name
        menuCollectionView.reloadData()
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = WriteDetailMenuItemCell.Layout.size
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        return layout
    }
}

extension WriteDetailMenuGroupCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.menus.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WriteDetailMenuItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(viewModel: viewModel, index: indexPath.row)
        
        return cell
    }
}
