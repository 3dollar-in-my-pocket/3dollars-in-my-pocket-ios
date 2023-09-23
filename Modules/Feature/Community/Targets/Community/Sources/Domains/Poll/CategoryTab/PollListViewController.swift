import UIKit

import DesignSystem
import Common

final class PollListViewController: BaseViewController {

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.register([PollItemCell.self])
    }

    private lazy var dataSource = PollListDataSource(collectionView: collectionView)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubViews([
            collectionView
        ])

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindEvent() {
        super.bindEvent()

        dataSource.reload([
            .init(items: [
                .poll("1"),
                .poll("2"),
                .poll("3"),
                .poll("4")
            ])
        ])
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        return layout
    }
}
