import UIKit

import Common
import DesignSystem

final class BookmarkEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 270
    }
    
    private let emptyImage: UIImageView = {
        let imageVIew = UIImageView()
        
//        imageVIew.image =
        return imageVIew
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        
        label.text = "즐겨찾기 리스트가 없어요.\n가게 상세에서 추가해주세요!"
        label.numberOfLines = 2
        label.textColor = Colors.gray60.color
        label.font = Fonts.bold.font(size: 16)
        return label
    }()
    
    override func setup() {
        contentView.addSubViews([
            emptyImage,
            emptyLabel
        ])
    }
    
    override func bindConstraints() {
        emptyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(101)
            $0.width.equalTo(112)
            $0.height.equalTo(112)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyImage.snp.bottom).offset(8)
        }
    }
}
