import UIKit

import Common
import DesignSystem
import Model

final class HomeListEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 220
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray80.color
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "주변에 등록된 가게가 없어요"
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 13)
        label.textColor = Colors.gray60.color
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "지도를 움직여 다른 위치를 살펴보세요"
        return label
    }()

    override func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(48)
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-48)
        }
    }
}
