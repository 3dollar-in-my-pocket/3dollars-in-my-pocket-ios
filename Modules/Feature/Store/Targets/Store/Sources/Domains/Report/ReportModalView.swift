import UIKit
import Combine

import Common
import DesignSystem

final class ReportModalView: BaseView {
    enum Layout {
        static let space: CGFloat = 6
        static func calculateCollectionViewHeight(itemCount: Int) -> CGFloat {
            let itemHeight = ReportReasonCell.Layout.size.height * CGFloat(itemCount)
            let space: CGFloat = Layout.space * CGFloat(itemCount - 1)
            
            return itemHeight + space
        }
    }
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.delete.image.withTintColor(Colors.gray40.color), for: .normal)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.text = Strings.ReportModal.title
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        let text = Strings.ReportModal.description
        let range = (text as NSString).range(of: Strings.ReportModal.descriptionBold)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([.foregroundColor: Colors.gray80.color], range: range)
        label.attributedText = attributedString
        
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = ReportReasonCell.Layout.size
        layout.minimumInteritemSpacing = ReportModalView.Layout.space
        layout.minimumLineSpacing = ReportModalView.Layout.space
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register([ReportReasonCell.self])
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    let reportButon: Button.Normal = {
        let button = Button.Normal(size: .h48, text: Strings.ReportModal.button)
        button.enabledBackgroundColor = Colors.mainRed.color
        return button
    }()
    
    override func setup() {
        addSubViews([
            titleLabel,
            closeButton,
            descriptionLabel,
            collectionView,
            reportButon
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(30)
            $0.centerY.equalTo(titleLabel)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.height.equalTo(0)
        }
        
        reportButon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20).priority(.high)
            $0.right.equalToSuperview().offset(-20).priority(.high)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }
    
    func updateCollectionViewHeight(itemCount: Int) {
        collectionView.snp.updateConstraints {
            $0.height.equalTo(Layout.calculateCollectionViewHeight(itemCount: itemCount))
        }
    }
}
