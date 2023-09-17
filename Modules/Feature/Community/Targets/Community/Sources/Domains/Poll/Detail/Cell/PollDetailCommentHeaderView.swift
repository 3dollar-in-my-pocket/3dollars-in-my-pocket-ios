import UIKit

import DesignSystem
import Then

final class PollDetailCommentHeaderView: UICollectionReusableView {

    enum Layout {
        static let height: CGFloat = 48
    }

    private let countLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray100.color
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let stackView = UIStackView(arrangedSubviews: [
            UIImageView(image: Icons.communitySolid.image
                .resizeImage(scaledTo: 20)
                .withTintColor(Colors.mainRed.color)),
            countLabel,
            UILabel().then {
                $0.text = "의견"
                $0.font = Fonts.regular.font(size: 14)
                $0.textColor = Colors.gray100.color
            }
        ])

        stackView.axis = .horizontal
        stackView.spacing = 2

        addSubViews([stackView])

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }

    func bind(count: Int) {
        countLabel.text = "\(count)개"
    }
}
