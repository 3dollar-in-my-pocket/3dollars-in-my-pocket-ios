import UIKit
import Combine

import Common
import Model

extension HomeFilterCollectionView {
    enum Layout {
        static let interItemSpacing: CGFloat = 10

        static func createLayout() -> UICollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = Layout.interItemSpacing
            layout.scrollDirection = .horizontal
            return layout
        }
    }

    enum CellType: Hashable {
        case chip(SDChip, surface: SDSurfaceStyle?, action: ChipAction)
        case button(SDButton, surface: SDSurfaceStyle?)
        case selectedCategoryChip(SDChip)
    }

    enum ChipAction: Hashable {
        case openCategoryFilter
        case selectRadio(paramKey: String, optionIndex: Int)
        case openLink(SDLink)
    }
}

final class HomeFilterCollectionView: UICollectionView {
    var onLoadFilter: (() -> Void)?
    private var datasource: [CellType] = []
    private let homeFilterSelectable: HomeFilterSelectable
    private var cancellables = Set<AnyCancellable>()
    private var isFirstLoad = true

    /// 첫 RADIO_BAR 칩의 IndexPath (없으면 nil). HomeView 의 tooltip 위치 계산용.
    var firstRadioCellIndexPath: IndexPath? {
        guard let index = datasource.firstIndex(where: { cell in
            if case .chip(_, _, .selectRadio) = cell { return true }
            return false
        }) else { return nil }
        return IndexPath(item: index, section: 0)
    }

    init(homeFilterSelectable: HomeFilterSelectable) {
        self.homeFilterSelectable = homeFilterSelectable
        super.init(frame: .zero, collectionViewLayout: Layout.createLayout())

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        register([
            HomeFilterCell.self,
            BaseCollectionViewCell.self
        ])

        showsHorizontalScrollIndicator = false
        contentInset = .init(top: 13, left: 22, bottom: 13, right: 22)

        delegate = self
        dataSource = self

        homeFilterSelectable.filterDatasource
            .main
            .withUnretained(self)
            .sink { (owner: HomeFilterCollectionView, datasource: [CellType]) in
                owner.datasource = datasource
                owner.reloadData()

                if owner.isFirstLoad {
                    owner.isFirstLoad = false
                    DispatchQueue.main.async {
                        owner.onLoadFilter?()
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension HomeFilterCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }

        switch item {
        case .chip(let chip, let surface, _):
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(chip: chip, surface: surface)
            return cell
        case .button(let button, let surface):
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(button: button, surface: surface)
            return cell
        case .selectedCategoryChip(let chip):
            let cell: HomeFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bindSelectedCategory(chip: chip) { [weak self] in
                self?.homeFilterSelectable.selectCategory.send(nil)
            }
            return cell
        }
    }
}

extension HomeFilterCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = datasource[safe: indexPath.item] else { return .zero }

        switch item {
        case .chip(let chip, _, _):
            return HomeFilterCell.Layout.size(for: chip)
        case .button(let button, _):
            return HomeFilterCell.Layout.size(for: button)
        case .selectedCategoryChip(let chip):
            return HomeFilterCell.Layout.sizeForSelectedCategory(chip: chip)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = datasource[safe: indexPath.item] else { return }

        switch item {
        case .chip(_, _, let action):
            handleAction(action)
        case .button(let button, _):
            if let link = button.link {
                homeFilterSelectable.onTapActionLink.send(link)
            }
        case .selectedCategoryChip:
            break
        }
    }

    private func handleAction(_ action: ChipAction) {
        switch action {
        case .openCategoryFilter:
            homeFilterSelectable.onTapCategoryFilter.send(())
        case .selectRadio(let paramKey, let optionIndex):
            homeFilterSelectable.onTapRadioOption.send((paramKey, optionIndex))
        case .openLink(let link):
            homeFilterSelectable.onTapActionLink.send(link)
        }
    }
}
