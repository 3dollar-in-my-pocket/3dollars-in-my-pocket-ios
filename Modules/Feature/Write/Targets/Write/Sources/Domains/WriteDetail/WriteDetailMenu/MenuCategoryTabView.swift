import UIKit

import Common
import DesignSystem
import Model

final class MenuCategoryTabView: BaseView {
    enum Layout {
        static let height: CGFloat = 48
        static let filterAreaWidth: CGFloat = 52
    }

    var onSelectCategory: ((Int) -> Void)?
    var onTapFilter: (() -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return collectionView
    }()

    private let bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        return view
    }()

    private let filterContainerView = UIView()

    private let filterButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.iconFilter.image.resizeImage(scaledTo: 18), for: .normal)
        button.backgroundColor = Colors.systemWhite.color
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray20.color.cgColor
        return button
    }()

    private let filterGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            Colors.systemWhite.color.withAlphaComponent(0).cgColor,
            Colors.systemWhite.color.cgColor
        ]
        layer.locations = [0, 0.27]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private let showsFilterButton: Bool
    private var categories: [StoreFoodCategoryResponse] = []
    private var selectedIndex = 0

    init(showsFilterButton: Bool) {
        self.showsFilterButton = showsFilterButton
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        backgroundColor = Colors.systemWhite.color
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([MenuCategoryTabCell.self])

        addSubViews([
            collectionView,
            bottomLineView,
            filterContainerView
        ])
        filterContainerView.layer.addSublayer(filterGradientLayer)
        filterContainerView.addSubview(filterButton)
        filterContainerView.isHidden = showsFilterButton.isNot
        filterButton.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
    }

    override func bindConstraints() {
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomLineView.snp.top)
        }

        bottomLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        filterContainerView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomLineView.snp.top)
            $0.width.equalTo(Layout.filterAreaWidth)
        }

        filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(28)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        filterGradientLayer.frame = filterContainerView.bounds
        if showsFilterButton {
            collectionView.contentInset.right = Layout.filterAreaWidth
        }
    }

    func bind(categories: [StoreFoodCategoryResponse], selectedIndex: Int) {
        self.categories = categories
        self.selectedIndex = selectedIndex
        collectionView.reloadData()
        guard categories.indices.contains(selectedIndex) else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
    }

    @objc private func didTapFilter() {
        onTapFilter?()
    }
}

extension MenuCategoryTabView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MenuCategoryTabCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let category = categories[safe: indexPath.item] {
            cell.bind(title: category.name, isSelected: indexPath.item == selectedIndex)
        }
        return cell
    }
}

extension MenuCategoryTabView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else { return }
        onSelectCategory?(indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let title = categories[safe: indexPath.item]?.name ?? ""
        return CGSize(width: MenuCategoryTabCell.Layout.width(title: title), height: Layout.height - 1)
    }
}

final class MenuCategoryTabCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalPadding: CGFloat = 12

        static func width(title: String) -> CGFloat {
            let titleWidth = (title as NSString).size(withAttributes: [.font: Fonts.bold.font(size: 16)]).width
            return ceil(titleWidth) + horizontalPadding * 2
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray100.color
        return view
    }()

    override func setup() {
        contentView.addSubViews([
            titleLabel,
            indicatorView
        ])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        indicatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
    }

    func bind(title: String, isSelected: Bool) {
        titleLabel.text = title
        titleLabel.font = isSelected ? Fonts.bold.font(size: 16) : Fonts.medium.font(size: 16)
        titleLabel.textColor = isSelected ? Colors.gray100.color : Colors.gray60.color
        indicatorView.isHidden = isSelected.isNot
    }
}
