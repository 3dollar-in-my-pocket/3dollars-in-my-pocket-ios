import UIKit
import Combine

open class BaseTableViewCell: UITableViewCell {
    public var cancellables = Set<AnyCancellable>()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        bindConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        cancellables = Set<AnyCancellable>()
    }

    /// adSubviews와 화면의 기본 속성을 설정합니다.
    open func setup() { }

    /// Autolayout설정을 진행합니다.
    open func bindConstraints() { }
}
