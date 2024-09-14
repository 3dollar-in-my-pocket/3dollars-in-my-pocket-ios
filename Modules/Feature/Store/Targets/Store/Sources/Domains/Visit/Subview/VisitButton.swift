import UIKit

import Common
import DesignSystem
import Model

final class VisitButton: UIButton {
    enum Layout {
        static let width: CGFloat = (UIUtils.windowBounds.width - 63) / 2
        static let size = CGSize(width: width, height: width)
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.axis = .vertical
        stackView.alignment = .center
        
        return stackView
    }()
    
    private let visitImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        
        return imageView
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    init(type: VisitType) {
        super.init(frame: .zero)
        
        setup()
        bindConstraints()
        bind(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(type: VisitType) {
        visitImage.image = type.image
        subjectLabel.text = type.subject
        subjectLabel.textColor = type.subjectTextColor
    }
    
    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 20
        
        stackView.addArrangedSubview(visitImage)
        stackView.addArrangedSubview(subjectLabel)
        addSubViews([
            stackView
        ])
    }
    
    private func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        visitImage.snp.makeConstraints {
            $0.size.equalTo(88)
        }
        
        subjectLabel.snp.makeConstraints {
            $0.height.equalTo(28)
        }
    }
}

extension VisitType {
    var image: UIImage? {
        switch self {
        case .exists:
            return Assets.imageSuccessVisit.image
        case .notExists:
            return Assets.imageFailVisit.image
        case .unknown:
            return nil
        }
    }
    
    var subject: String {
        switch self {
        case .exists:
            return Strings.Visit.exists
        case .notExists:
            return Strings.Visit.notExists
        case .unknown:
            return ""
        }
    }
    
    var subjectTextColor: UIColor? {
        switch self {
        case .exists:
            return Colors.mainGreen.color
        case .notExists:
            return Colors.mainRed.color
        case .unknown:
            return nil
        }
    }
}
