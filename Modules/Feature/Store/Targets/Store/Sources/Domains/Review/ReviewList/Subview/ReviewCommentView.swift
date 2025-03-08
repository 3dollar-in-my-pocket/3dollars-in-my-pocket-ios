import UIKit
import Combine

import Common
import DesignSystem
import Model

final class ReviewCommentView: BaseView {
    private let triangleView = TriangleView(size: CGSize(width: 16, height: 12))
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.bold.font(size: 12)
        
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.regular.font(size: 14)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        bindEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        backgroundColor = .clear
    }
    
    override func bindConstraints() {
        addSubViews([triangleView, containerView])
        containerView.addSubViews([nameLabel, dateLabel, contentLabel])
        
        triangleView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(triangleView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func bindEvent() {
        
    }
    
    func bind(comment: StoreDetailReviewComment) {
        nameLabel.text = comment.name
        dateLabel.text = DateUtils.toString(dateString: comment.updatedAt, format: "yyyy.MM.dd")
        contentLabel.text = comment.content
        contentLabel.setLineHeight(lineHeight: 20)
        containerView.backgroundColor = comment.isOwner ? Colors.systemWhite.color : Colors.gray10.color
        triangleView.setColor(comment.isOwner ? Colors.systemWhite.color : Colors.gray10.color)
    }
}

private final class TriangleView: UIView {
    private var shapeLayer: CAShapeLayer?
    
    private var fillColor: UIColor = .clear {
        didSet {
            shapeLayer?.fillColor = fillColor.cgColor
        }
    }
    
    private let size: CGSize
    
    init(size: CGSize = CGSize(width: 16, height: 12)) {
        self.size = size
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        snp.makeConstraints {
            $0.size.equalTo(size)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        createTriangle()
    }

    private func createTriangle() {
        guard shapeLayer.isNil else { return }
        
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height

        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        layer.addSublayer(shapeLayer)
        
        self.shapeLayer = shapeLayer
    }
    
    func setColor(_ color: UIColor) {
        self.fillColor = color
        shapeLayer?.fillColor = fillColor.cgColor
    }
}
