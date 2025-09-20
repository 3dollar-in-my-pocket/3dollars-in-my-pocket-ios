import UIKit
import SnapKit

import DesignSystem
import Common
import Model

final class EditStoreInfoView: BaseView {
    let tapGesture = UITapGestureRecognizer()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = WriteAsset.iconMegaphone.image
            .withImageInset(insets: .init(top: 4, left: 4, bottom: 4, right: 4))
        imageView.backgroundColor = Colors.gray10.color
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "가게 정보"
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 14)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private let nameItemView = EditStoreInfoItemView(title: "가게 이름")
    private let typeItemVIew = EditStoreInfoItemView(title: "가게 형태")
    private let methodItemView = EditStoreInfoItemView(title: "결제 방식")
    private let appearanceDaysItemView = EditStoreInfoItemView(title: "출몰 요일")
    private let openingHoursItemView = EditStoreInfoItemView(title: "출몰 시간")
        
    override func setup() {
        super.setup()
        
        addGestureRecognizer(tapGesture)
        backgroundColor = Colors.systemWhite.color
        layer.cornerRadius = 16
        layer.shadowColor = Colors.systemBlack.color.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        
        addSubViews([
            iconView,
            titleLabel,
            stackView
        ])
        
        stackView.addArrangedSubview(nameItemView)
        stackView.addArrangedSubview(typeItemVIew)
        stackView.addArrangedSubview(methodItemView)
        stackView.addArrangedSubview(appearanceDaysItemView)
        stackView.addArrangedSubview(openingHoursItemView)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(8)
            $0.top.equalTo(iconView)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(154)
        }
    }
    
    func bind(store: UserStoreResponse) {
        nameItemView.bind(value: store.name)
        typeItemVIew.bind(value: store.salesTypeV2?.description)
        methodItemView.bind(value: store.paymentMethods.strings)
        appearanceDaysItemView.bind(value: store.appearanceDays.strings)
        
        
        let startTime = store.openingHours?.startTime?.toDate(format: "HH:mm")?.toString(format: Strings.WriteAdditionalInfo.OpeningHours.dateFormat) ?? ""
        let endTime = store.openingHours?.endTime?.toDate(format: "HH:mm")?.toString(format: Strings.WriteAdditionalInfo.OpeningHours.dateFormat) ?? ""
        let openingHourString = startTime.isNotEmpty || endTime.isNotEmpty ? "\(startTime) ~ \(endTime)" : nil
        openingHoursItemView.bind(value: openingHourString)
    }
}

final class EditStoreInfoItemView: BaseView {
    private let checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = WriteAsset.iconCheck.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.gray40.color
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        addSubViews([
            checkImage,
            titleLabel,
            valueLabel
        ])
    }
    
    override func bindConstraints() {
        checkImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(12)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImage.snp.trailing).offset(4)
            $0.top.bottom.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
            $0.centerY.equalTo(titleLabel)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
    
    func bind(value: String?) {
        let tintColor: UIColor = (value?.isNotEmpty ?? false) ? Colors.mainPink.color : Colors.gray40.color
        
        if let value, value.isNotEmpty {
            valueLabel.text = value
            valueLabel.textColor = Colors.gray60.color
        } else {
            valueLabel.text = "제보된 정보가 없어요"
            valueLabel.textColor = Colors.gray50.color
        }
        checkImage.tintColor = tintColor
        titleLabel.textColor = tintColor
    }
}

private extension Array where Element == PaymentMethod {
    var strings: String {
        self.sorted().map { $0.string }.joined(separator: ",")
    }
}

private extension PaymentMethod {
    var string: String {
        switch self {
        case .accountTransfer:
            "계좌 이체"
        case .card:
            "카드"
        case .cash:
            "현금"
        case .unknown:
            ""
        }
    }
}

private extension Array where Element == AppearanceDay {
    var strings: String {
        self.sorted().map { $0.string }.joined(separator: ",")
    }
}

private extension AppearanceDay {
    var string: String {
        switch self {
        case .monday:
            "월"
        case .tuesday:
            "화"
        case .wednesday:
            "수"
        case .thursday:
            "목"
        case .friday:
            "금"
        case .saturday:
            "토"
        case .sunday:
            "일"
        case .unknown:
            ""
        }
    }
}
