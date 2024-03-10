import UIKit

import Common
import DesignSystem

final class BookmarkViewerSectionHeaderView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 54
    }
    
    private let countLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.mainPink.color
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubViews([countLabel])
    }
    
    private func bindConstraints() {
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
        }
    }
    
    func bind(totalCount: Int?) {
        let text: String?
        
        if let totalCount {
            text = "\(totalCount)개의 리스트"
        } else {
            text = nil
        }
        countLabel.text = text
    }
}
