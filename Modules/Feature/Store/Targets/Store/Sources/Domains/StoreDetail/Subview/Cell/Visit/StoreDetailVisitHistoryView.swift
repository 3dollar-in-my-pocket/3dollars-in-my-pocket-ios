import UIKit

import Common
import DesignSystem

final class StoreDetailVisitHistoryView: BaseView {
    enum Layout {
        static let itemHeight: CGFloat = 18
        static let space: CGFloat = 4
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.space
        
        return stackView
    }()
    
    override func setup() {
        containerView.addSubview(stackView)
        addSubview(containerView)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(12)
        }
    }
}
