import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// 광고 SDK가 `cardId`로 실제 광고를 채운다. SDK 로드 전에는 예약된 광고 영역만 유지한다.
final class StoreAdmobCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 12
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 11)
        label.textColor = Colors.gray50.color
        label.text = "AD"
        return label
    }()

    private(set) var card: StoreAdmobCard?

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
        card = nil
    }

    override func setup() {
        contentView.addSubview(placeholderView)
        placeholderView.addSubview(label)
    }

    override func bindConstraints() {
        placeholderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(80)
        }
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func bind(_ section: StoreAdmobSection) {
        card = section.cards.first
        placeholderView.isHidden = card == nil
        placeholderView.gestureRecognizers?.forEach(placeholderView.removeGestureRecognizer)
        if let card {
            placeholderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAd)))
        }
    }

    @objc private func didTapAd() {
        guard let card else { return }
        onAction?(.custom(.init(actionType: .unknown), clickLog: card.clickLog))
    }
}
