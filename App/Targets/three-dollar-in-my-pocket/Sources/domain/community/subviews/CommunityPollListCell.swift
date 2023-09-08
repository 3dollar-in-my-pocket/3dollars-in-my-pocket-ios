import UIKit

import Common
import DesignSystem

final class CommunityPollListCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 426)
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.Pretendard.bold.font(size: 24)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 2
        $0.text = "그만싸워 얘덜아...\n먹을걸로 왜그래..."
    }

    let moreButton = UIButton().then {
        $0.titleLabel?.font = Fonts.Pretendard.bold.font(size: 18)
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

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            moreButton,
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

        moreButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(moreButton)
            $0.leading.equalTo(moreButton.snp.trailing).offset(2)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(moreButton.snp.bottom).offset(12)
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
}

extension CommunityPollListCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind()
        return cell
    }
}

extension CommunityPollListCell: UICollectionViewDelegate {

}
