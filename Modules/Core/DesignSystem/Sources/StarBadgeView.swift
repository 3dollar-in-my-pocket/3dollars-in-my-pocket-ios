import UIKit

public final class StarBadgeView: UIView {
    public enum Layout {
        public static let size = CGSize(width: 68, height: 20)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addSubview(stackView)
    }
    
    private func bindConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4)
        ])
        
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            self.topAnchor.constraint(equalTo: containerView.topAnchor),
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    public func prepareForReuse() {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    public func bind(_ rating: Int) {
        for index in 0..<5 {
            if rating >= index + 1 {
                let image = DesignSystemAsset.Icons.starSolid.image.withTintColor(DesignSystemAsset.Colors.mainPink.color)
                let starImageView = UIImageView(image: image)
                starImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    starImageView.widthAnchor.constraint(equalToConstant: 12),
                    starImageView.heightAnchor.constraint(equalToConstant: 12)
                ])
                
                stackView.addArrangedSubview(starImageView)
            } else {
                let image = DesignSystemAsset.Icons.starSolid.image.withTintColor(DesignSystemAsset.Colors.gray70.color)
                let starImageView = UIImageView(image: image)
                starImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    starImageView.widthAnchor.constraint(equalToConstant: 12),
                    starImageView.heightAnchor.constraint(equalToConstant: 12)
                ])
                
                stackView.addArrangedSubview(starImageView)
            }
        }
    }
}
