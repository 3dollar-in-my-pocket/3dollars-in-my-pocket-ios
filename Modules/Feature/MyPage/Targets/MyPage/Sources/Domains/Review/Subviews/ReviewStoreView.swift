import UIKit

import Common
import DesignSystem
import Model

final class ReviewStoreView: BaseView {

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.mainPink.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray80.color
        return view
    }()
    
    override func setup() {
        addSubViews([
            imageView,
            nameLabel,
            dividerView
        ])
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.centerY.equalTo(imageView)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(nameLabel)
        }
    }
    
    func bind(_ store: PlatformStore) {
        imageView.setImage(urlString: store.categories.first?.imageUrl)
        nameLabel.text = store.name
    }
}
