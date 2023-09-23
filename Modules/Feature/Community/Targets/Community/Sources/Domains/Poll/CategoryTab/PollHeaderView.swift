import UIKit

import DesignSystem
import Then

final class PollHeaderView: UICollectionReusableView {

    enum Layout {
        static let height: CGFloat = 98
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.gray100.color
    }

    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubViews([
            titleLabel,
            descriptionLabel
        ])

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(20)
        }
    }

    func bind() {
        titleLabel.text = "13시 인기 투표"
        descriptionLabel.text = "인기 투표는 1시간 간격으로 업데이트 돼요"
    }
}
