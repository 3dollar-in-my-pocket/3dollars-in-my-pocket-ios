import UIKit
import Combine

import Common
import DesignSystem
import Then

final class CommunityPollListCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 426)
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 2
        $0.text = "그만싸워 얘덜아...\n먹을걸로 왜그래..."
    }

    private let categoryButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 18)
        $0.setTitle("맛짱 투표", for: .normal)
        $0.setTitleColor(Colors.gray80.color, for: .normal)
        $0.setImage(Icons.fireSolid.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.mainRed.color), for: .normal)
    }

    private let arrowImageView = UIImageView().then {
        $0.image = Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray80.color)
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        $0.showsHorizontalScrollIndicator = false
        $0.register([PollItemCell.self])
        $0.dataSource = self
        $0.delegate = self
    }

    private var viewModel: CommunityPollListCellViewModel?

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            categoryButton,
            arrowImageView,
            collectionView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        categoryButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(categoryButton)
            $0.leading.equalTo(categoryButton.snp.trailing).offset(2)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(categoryButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = PollItemCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        return layout
    }

    func bind(viewModel: CommunityPollListCellViewModel) {
        self.viewModel = viewModel

        // Input
        categoryButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didSelectCategory)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.pollList
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.collectionView.reloadData()
                owner.scrollToStoredContentOffset()
            }
            .store(in: &cancellables)
    }

    private func scrollToStoredContentOffset() {
        if let contentOffset = viewModel?.output.storedContentOffset.value {
            collectionView.contentOffset = contentOffset
        } else {
            collectionView.scrollToTop(animated: false)
        }
    }
}

extension CommunityPollListCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.pollList.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellViewModel = viewModel?.output.pollList.value[safe: indexPath.item] else { return UICollectionViewCell() }

        let cell: PollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(viewModel: cellViewModel)
        return cell
    }
}

extension CommunityPollListCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didSelectPollItem.send(indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = collectionView.contentOffset
        viewModel?.input.updateStoredContentOffset.send(contentOffset)
    }
}
