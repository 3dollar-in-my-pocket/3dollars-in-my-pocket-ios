import UIKit

public final class TooltipView: UIView {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.layoutMargins = .init(top: 8, left: 12, bottom: 8, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = UIColor(red: 35/255, green: 36/255, blue: 42/255, alpha: 1)
        stackView.layer.cornerRadius = 8
        stackView.layer.masksToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    public var didTap: (() -> Void)?
    private let tailDirection: TailDirection
    private let tapGesture = UITapGestureRecognizer()
    
    public init(emoji: String, message: String, tailDirection: TailDirection) {
        self.tailDirection = tailDirection
        super.init(frame: .zero)
        
        setup()
        bind(emoji: emoji, message: message)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(stackView)
        addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapView))
        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(messageLabel)
        
        setupTriangleView()
    }
    
    private func setupTriangleView() {
        let triangleView = tailDirection.triangleView
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(triangleView)
        
        switch tailDirection {
        case .bottomCenter:
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: self.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            NSLayoutConstraint.activate([
                triangleView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
                triangleView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
                triangleView.widthAnchor.constraint(equalToConstant: 10),
                triangleView.heightAnchor.constraint(equalToConstant: 6)
            ])
            
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                self.topAnchor.constraint(equalTo: stackView.topAnchor),
                self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: triangleView.bottomAnchor)
            ])
        case .topRight:
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: triangleView.bottomAnchor),
                stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            NSLayoutConstraint.activate([
                triangleView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -21),
                triangleView.widthAnchor.constraint(equalToConstant: 10),
                triangleView.heightAnchor.constraint(equalToConstant: 6),
                triangleView.topAnchor.constraint(equalTo: self.topAnchor)
            ])
            
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
                self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                self.topAnchor.constraint(equalTo: triangleView.topAnchor)
            ])
        case .topLeft:
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: triangleView.bottomAnchor),
                stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            NSLayoutConstraint.activate([
                triangleView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 30),
                triangleView.widthAnchor.constraint(equalToConstant: 10),
                triangleView.heightAnchor.constraint(equalToConstant: 6),
                triangleView.topAnchor.constraint(equalTo: self.topAnchor)
            ])
            
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
                self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                self.topAnchor.constraint(equalTo: triangleView.topAnchor)
            ])
        }
    }
    
    private func bind(emoji: String, message: String) {
        emojiLabel.text = emoji
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20
        
        let attributedString = NSMutableAttributedString(
            string: message,
            attributes: [
                .paragraphStyle: style,
                .font: DesignSystemFontFamily.Pretendard.regular.font(size: 14) as Any,
                .foregroundColor: UIColor.white
            ]
        )
        messageLabel.attributedText = attributedString
    }
    
    @objc private func didTapView() {
        didTap?()
    }
}

extension TooltipView {
    public enum TailDirection {
        case topRight
        case bottomCenter
        case topLeft
        
        var triangleView: UIView {
            switch self {
            case .topRight:
                return UpperTriangleView(width: 10, height: 6)
            case .bottomCenter:
                return LowerTriangleView(width: 10, height: 6)
            case .topLeft:
                return UpperTriangleView(width: 10, height: 6)
            }
        }
    }
    
    final class UpperTriangleView: UIView {
        init(width: CGFloat, height: CGFloat) {
            let frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
            super.init(frame: frame)
            backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.close()
            
            UIColor(red: 35/255, green: 36/255, blue: 42/255, alpha: 1).setFill()
            path.fill()
        }
    }
    
    final class LowerTriangleView: UIView {
        init(width: CGFloat, height: CGFloat) {
            let frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
            super.init(frame: frame)
            backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.close()
            
            UIColor(red: 35/255, green: 36/255, blue: 42/255, alpha: 1).setFill()
            path.fill()
        }
    }
}
