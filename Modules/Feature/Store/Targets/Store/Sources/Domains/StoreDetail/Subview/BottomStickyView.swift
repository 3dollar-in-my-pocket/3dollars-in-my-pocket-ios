import UIKit

import DesignSystem
import Common
import SnapKit

final class BottomStickyView: BaseView {
    enum Layout {
        static let height: CGFloat = UIUtils.bottomSafeAreaInset + 71
    }
    
    private let divider = UIView().then {
        $0.backgroundColor = Colors.gray20.color
    }
    
    let saveButton = Button.Normal(
        size: .h48,
        text: Strings.StoreDetail.BottomSticky.save,
        leftIcon: Icons.bookmarkLine.image
    ).then {
        $0.tintColor = Colors.gray70.color
        $0.backgroundColor = .clear
        $0.setTitleColor(Colors.gray70.color, for: .normal)
        $0.contentEdgeInsets = .init(top: 12, left: 21, bottom: 12, right: 21)
    }
    
    let visitButton = Button.Normal(
        size: .h48,
        text: Strings.StoreDetail.BottomSticky.visit
    )
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            divider,
            saveButton,
            visitButton
        ])
    }
    
    override func bindConstraints() {
        divider.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        saveButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(divider.snp.bottom).offset(12)
        }
        
        visitButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(saveButton)
            $0.left.equalTo(saveButton.snp.right).offset(16)
        }
    }
    
    func setSaved(_ isSaved: Bool) {
        if isSaved {
            saveButton.leftIcon = Icons.bookmarkSolid.image
            saveButton.tintColor = Colors.mainRed.color
            saveButton.setTitleColor(Colors.mainRed.color, for: .normal)
        } else {
            saveButton.leftIcon = Icons.bookmarkLine.image
            saveButton.tintColor = Colors.gray70.color
            saveButton.setTitleColor(Colors.gray70.color, for: .normal)
        }
    }
}
