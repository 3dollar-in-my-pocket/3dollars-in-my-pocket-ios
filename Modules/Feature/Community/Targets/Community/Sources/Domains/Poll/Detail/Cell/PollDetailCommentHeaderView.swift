import UIKit

import DesignSystem

final class PollDetailCommentHeaderView: UICollectionReusableView {

    enum Layout {
        static let height: CGFloat = 68
    }

    private let countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = Fonts.semiBold.font(size: 14)
        countLabel.textColor = Colors.gray100.color
        return countLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let titleLabel = UILabel()
        titleLabel.text = "의견"
        titleLabel.font = Fonts.regular.font(size: 14)
        titleLabel.textColor = Colors.gray100.color

        let stackView = UIStackView(arrangedSubviews: [
            UIImageView(image: Icons.communitySolid.image
                .resizeImage(scaledTo: 20)
                .withTintColor(Colors.mainRed.color)),
            countLabel,
            titleLabel
        ])

        stackView.axis = .horizontal
        stackView.spacing = 2

        addSubViews([stackView])

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }

    func bind(count: Int) {
        countLabel.text = "\(count)개"
    }
}
