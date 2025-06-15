import UIKit
import Common
import DesignSystem

final class StoreDetailImageMenuEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 78
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = Colors.gray0.color
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.BossStoreDetail.Menu.empty
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.empty02.image
        return imageView
    }()
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            titleLabel,
            emptyImage
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyImage.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(emptyImage.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
