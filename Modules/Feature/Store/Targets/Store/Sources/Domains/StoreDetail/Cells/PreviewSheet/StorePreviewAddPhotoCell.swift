import UIKit

import Common
import DesignSystem

final class StorePreviewAddPhotoCell: BaseCollectionViewCell {
    private let dashedBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = Colors.gray30.color.cgColor
        layer.lineWidth = 1
        layer.lineDashPattern = [4, 4]
        return layer
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.plus.image.resizeImage(scaledTo: 24).withTintColor(Colors.gray50.color)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "사진 추가"
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray50.color
        return label
    }()
    
    private var contentStack: UIStackView?

    override func setup() {
        contentView.backgroundColor = Colors.gray0.color
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.layer.addSublayer(dashedBorderLayer)

        let contentStack = UIStackView(arrangedSubviews: [iconImageView, captionLabel])
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 2
        contentStack.isUserInteractionEnabled = false
        contentView.addSubview(contentStack)
        self.contentStack = contentStack
    }

    override func bindConstraints() {
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        contentStack?.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedBorderLayer.frame = contentView.bounds
        dashedBorderLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 10).cgPath
    }
}
