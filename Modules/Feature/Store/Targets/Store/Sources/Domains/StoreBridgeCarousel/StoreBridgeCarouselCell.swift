import UIKit
import Common
import DesignSystem
import SnapKit
import Then
import Model

final class StoreBridgeCarouselCell: BaseCollectionViewCell {
    private let containerView = StoreBridgeCarouselView()
    private var viewModel: StoreBridgeCarouselViewModel?
    
    override func setup() {
        contentView.addSubview(containerView)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ viewModel: StoreBridgeCarouselViewModel) {
        self.viewModel = viewModel
        containerView.bind(viewModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}

extension StoreBridgeCarouselCell {
    enum Layout {
        static func height(for items: [StoreImagePreviewCard]) -> CGFloat {
            guard let _ = items.first else { return 200 }
            let maxImageHeight = items.map { $0.image.style.height }.max() ?? 68
            let collectionViewHeight = maxImageHeight + StoreBridgeCarouselItemCell.Layout.spacing + StoreBridgeCarouselItemCell.Layout.bottomInfoHeight
            return 52 + collectionViewHeight + 16 // top margin + title height + spacing + collection view + bottom margin
        }
    }
}

final class StoreBridgeCarouselView: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 20)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 0
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.register([StoreBridgeCarouselItemCell.self])
        $0.dataSource = self
        $0.delegate = self
    }

    private var viewModel: StoreBridgeCarouselViewModel?

    private var collectionViewHeightConstraint: Constraint?

    override func setup() {
        addSubViews([titleLabel, collectionView])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    func bind(_ viewModel: StoreBridgeCarouselViewModel) {
        self.viewModel = viewModel
        
        if let headerTitle = viewModel.headerTitle {
            titleLabel.setSDText(headerTitle)
        }
        
        updateCollectionViewHeight(items: viewModel.output.items)
        
        if collectionView.collectionViewLayout is UICollectionViewFlowLayout {
            collectionView.collectionViewLayout = generateLayout()
        }
        
        collectionView.reloadData()
    }
    
    private func updateCollectionViewHeight(items: [StoreImagePreviewCard]) {
        guard !items.isEmpty else { return }
        
        let maxImageHeight = items.map { $0.image.style.height }.max() ?? 68
        let collectionViewHeight = maxImageHeight + StoreBridgeCarouselItemCell.Layout.spacing + StoreBridgeCarouselItemCell.Layout.bottomInfoHeight
        
        collectionViewHeightConstraint?.deactivate()
        collectionView.snp.makeConstraints {
            collectionViewHeightConstraint = $0.height.equalTo(collectionViewHeight).constraint
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        return layout
    }
}

extension StoreBridgeCarouselView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel?.output.items[safe: indexPath.item] else { return UICollectionViewCell() }
        let cell: StoreBridgeCarouselItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(item: item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didSelect.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = viewModel?.output.items[safe: indexPath.item] else {
            return CGSize(width: 80, height: 136)
        }
        return StoreBridgeCarouselItemCell.Layout.size(for: item.image.style)
    }
}
