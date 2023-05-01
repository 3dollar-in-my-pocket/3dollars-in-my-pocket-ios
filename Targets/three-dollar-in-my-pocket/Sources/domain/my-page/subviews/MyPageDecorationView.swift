import UIKit

final class MyPageDecorationView: BaseCollectionReusableView {
    static let registerId = "\(MyPageDecorationView.self)"
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = Color.gray100
    }

    override func setup() {
        self.addSubViews([
            self.backgroundView
        ])
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
