import UIKit

import RxSwift
import RxCocoa

final class BookmarkEmptyCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(BookmarkEmptyCollectionViewCell.self)"
    static let height: CGFloat = 270
    
    private let emptyImageView = UIImageView().then {
        $0.image = R.image.img_empty()
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "bookmark_list_empty".localized
        $0.font = .medium(size: 16)
        $0.textColor = R.color.gray1()
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override func setup() {
        self.addSubViews([
            self.emptyImageView,
            self.emptyLabel
        ])
    }
    
    override func bindConstraints() {
        self.emptyImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(92)
            make.width.equalTo(112)
            make.height.equalTo(112)
        }
        
        self.emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.emptyImageView.snp.bottom).offset(8)
        }
    }
}
