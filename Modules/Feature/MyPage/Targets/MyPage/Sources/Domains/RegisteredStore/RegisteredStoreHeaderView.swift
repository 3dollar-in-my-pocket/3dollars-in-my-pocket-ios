import UIKit

import DesignSystem
import Then

final class RegisteredStoreHeaderView: UICollectionReusableView {

    enum Layout {
        static let height: CGFloat = 64
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.systemWhite.color
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
            titleLabel
        ])

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    func bind(count: Int) {
        titleLabel.text = "\(count)개 제보하셨네요!"
    }
}
