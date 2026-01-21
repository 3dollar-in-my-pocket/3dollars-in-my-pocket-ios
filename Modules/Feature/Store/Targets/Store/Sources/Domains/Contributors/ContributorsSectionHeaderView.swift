import UIKit

final class ContributorsSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "ContributorsSectionHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "함께 만든 가게 정보"
        label.font = Fonts.semiBold.font(size: 24)
        label.textColor = Colors.gray100.color
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}
