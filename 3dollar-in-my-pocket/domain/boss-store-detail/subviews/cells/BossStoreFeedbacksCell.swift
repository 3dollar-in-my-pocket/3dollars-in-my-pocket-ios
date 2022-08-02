import UIKit

import Base

final class BossStoreFeedbacksCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreFeedbacksCell.self)"
    static let estimatedHeight: CGFloat = 521
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.backgroundColor = .white
        $0.layoutMargins = .init(top: 32, left: 0, bottom: 32, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stackView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        self.addSubViews([
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func bind(feedbacks: [BossStoreFeedback]) {
        for index in feedbacks.indices {
            let feedback = feedbacks[index]
            let itemView = self.generateStackItem(feedback: feedback, index: index)
            
            self.stackView.addArrangedSubview(itemView)
        }
    }
    
    private func generateStackItem(
        feedback: BossStoreFeedback,
        index: Int
    ) -> BossStoreFeedbackItemView {
        let itemView = BossStoreFeedbackItemView()
        
        itemView.bind(feedback: feedback, isTopRate: index < 3)
        return itemView
    }
}
