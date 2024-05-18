import UIKit

import DesignSystem


final class LikeButton: UIButton {
    private let selectedImage = Icons.heartFill.image
        .resizeImage(scaledTo: 16)
        .withTintColor(Colors.mainRed.color)
    private let normalImage = Icons.heartLine.image
        .resizeImage(scaledTo: 16)
        .withTintColor(Colors.gray60.color)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(count: Int, reactedByMe: Bool) {
        let state: UIControl.State = reactedByMe ? .selected : .normal
        setTitle("좋아요 \(count)", for: state)
        isSelected = reactedByMe
    }
    
    private func setup() {
        setTitle("좋아요", for: .normal)
        setTitleColor(Colors.gray60.color, for: .normal)
        setTitleColor(Colors.mainRed.color, for: .selected)
        titleLabel?.font = Fonts.medium.font(size: 10)
        setImage(selectedImage, for: .selected)
        setImage(normalImage, for: .normal)
        semanticContentAttribute = .forceLeftToRight
    }
}
