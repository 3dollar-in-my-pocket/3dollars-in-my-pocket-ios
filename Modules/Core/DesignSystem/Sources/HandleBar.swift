import UIKit

public final class HandleBar: UIView {
    public enum Layout {
        public static let height: CGFloat = 20
        public static let handleSize = CGSize(width: 40, height: 5)
        public static let handleTopInset: CGFloat = 7
        public static let handleColor = DesignSystemAsset.Colors.gray20.color
    }

    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = Layout.handleColor
        view.layer.cornerRadius = Layout.handleSize.height / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = false
        addSubview(handleView)
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            handleView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.handleTopInset),
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: Layout.handleSize.width),
            handleView.heightAnchor.constraint(equalToConstant: Layout.handleSize.height)
        ])
    }
}
