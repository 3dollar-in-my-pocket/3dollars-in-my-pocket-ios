import UIKit
import Common
import DesignSystem
import Model

final class BossStoreEmptyMenuCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 78
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 6
        $0.backgroundColor = Colors.gray0.color
    }

    private let titleLabel = UILabel().then {
        $0.text = "등록된 메뉴가 없습니다.\n사장님이 메뉴를 등록할 때 까지 잠시만 기다려주세요!"
        $0.textColor = Colors.gray50.color
        $0.font = Fonts.medium.font(size: 12)
        $0.numberOfLines = 0
    }

    private let emptyImage = UIImageView().then {
        $0.image = Icons.empty02.image
    }

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
