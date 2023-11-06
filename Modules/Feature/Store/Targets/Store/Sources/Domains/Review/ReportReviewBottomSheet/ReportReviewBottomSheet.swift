import UIKit

import Common
import DesignSystem

final class ReportReviewBottomSheet: BaseView {
    enum Layout {
        static let space: CGFloat = 6
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 20)
        label.text = Strings.ReviewBottomSheet.title
        
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deleteX.image.withTintColor(Colors.gray40.color), for: .normal)
        
        return button
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    let reportButton: Button.Normal = {
        let button = Button.Normal(size: .h48, text: Strings.ReportModal.button)
        button.enabledBackgroundColor = Colors.mainRed.color
        return button
    }()
    
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.space
        layout.minimumLineSpacing = Layout.space
        
        return layout
    }
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            titleLabel,
            closeButton,
            collectionView,
            reportButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(25)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.height.equalTo(0)
        }
        
        reportButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20).priority(.high)
            $0.right.equalToSuperview().offset(-20).priority(.high)
            $0.bottom.equalToSuperview().offset(-20 - UIUtils.bottomSafeAreaInset)
        }
    }
    
    func getCollectionViewHeight(sectionItems: [ReportReviewSectionItem]) -> CGFloat {
        var height: CGFloat = 0
        
        for sectionItem in sectionItems {
            switch sectionItem {
            case .reason:
                height += ReportReviewReasonCell.Layout.size.height
            case .reasonDetail:
                height += ReportReviewReasonDetailCell.Layout.size.height
            }
            height += Layout.space
        }
        
        return height
    }
}
