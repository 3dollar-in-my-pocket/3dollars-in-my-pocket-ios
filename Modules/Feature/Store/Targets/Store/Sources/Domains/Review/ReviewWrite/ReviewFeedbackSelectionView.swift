import UIKit

import Common
import DesignSystem

final class ReviewFeedbackSelectionView: BaseView {
    enum Constant {
        static let maxLengthOfReview = 100
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
    }
    
    private lazy var dataSource = BossStoreFeedbackDataSource(collectionView: collectionView)
    
    private let viewModel: ReviewFeedbackSelectionViewModel

    init(_ viewModel: ReviewFeedbackSelectionViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        
        bindEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            collectionView
        ])
    }
    
    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(330)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bindEvent() {
        // Output
        viewModel.output.dataSource
            .withUnretained(self)
            .main
            .sink { owner, sectionItems in
                owner.dataSource.reloadData(sectionItems: sectionItems)
            }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink {
                ToastManager.shared.show(message: $0)
            }
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        return layout
    }
}

extension ReviewFeedbackSelectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        viewModel.input.didSelectItem.send(item)
    }
}

extension ReviewFeedbackSelectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((UIScreen.main.bounds.width - 48) / 2)
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feedback:
            return CGSize(width: width, height: BossStoreFeedbackItemCell.Layout.height)
        case .none:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: BossStoreFeedbackHeaderCell.Layout.height)
    }
}
