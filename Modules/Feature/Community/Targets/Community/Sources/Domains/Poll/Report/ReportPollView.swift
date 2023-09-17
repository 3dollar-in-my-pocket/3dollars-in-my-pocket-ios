import UIKit

import DesignSystem
import Then
import Common

final class ReportPollView: BaseView {

    enum Layout {

    }

    let backgroundButton = UIButton()

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private let titleLabel = UILabel().then {
        $0.text = "신고 사유"
        $0.textColor = Colors.gray100.color
        $0.font = Fonts.semiBold.font(size: 20)
    }

    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }

    let reportButton = Button.Normal(size: .h48, text: "신고하기").then {
        $0.isEnabled = false
    }

    let closeButton = UIButton().then {
        $0.setImage(Icons.close.image.resizeImage(scaledTo: 16).withTintColor(.white), for: .normal)
        $0.backgroundColor = Colors.gray40.color
        $0.layer.cornerRadius = 12
    }

    override func setup() {
        super.setup()

        backgroundColor = .clear
        addSubViews([
            backgroundButton,
            containerView,
        ])

        containerView.addSubViews([
            titleLabel,
            collectionView,
            reportButton,
            closeButton
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        backgroundButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }

        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(244)
        }

        reportButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }

    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6

        return layout
    }
}
