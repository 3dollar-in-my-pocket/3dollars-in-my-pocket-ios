import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailBaseInfoCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 220
    }
    
    private let headerView = StoreDetailHeaderView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 12)
        label.text = Strings.StoreDetail.Info.storeType
        
        return label
    }()
    
    private let typeValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray70.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let appearanceDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 12)
        label.text = Strings.StoreDetail.Info.appearanceDay
        
        return label
    }()
    
    private let appearanceDayStackView = StoreDetailBaseInfoAppearanceDayStackView()
    
    private let openingHoursLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 12)
        label.text = Strings.StoreDetail.Info.openingHours
        
        return label
    }()
    
    private let openingHoursValueLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let paymentMethodLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 12)
        label.text = Strings.StoreDetail.Info.paymentMethod
        
        return label
    }()
    
    private let paymentMethodStackView = StoreDetailBaseInfoPaymentStackView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        paymentMethodStackView.prepareForReuse()
    }
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubViews([
            headerView,
            containerView,
            typeLabel,
            typeValueLabel,
            appearanceDayLabel,
            appearanceDayStackView,
            openingHoursLabel,
            openingHoursValueLabel,
            paymentMethodLabel,
            paymentMethodStackView
        ])
        
        headerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom).offset(12)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(152)
        }
        
        typeLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(17)
            $0.leading.equalTo(containerView).offset(16)
            $0.height.equalTo(18)
        }
        
        typeValueLabel.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.centerY.equalTo(typeLabel)
        }
        
        appearanceDayLabel.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(typeLabel)
            $0.height.equalTo(24)
        }
        
        appearanceDayStackView.snp.makeConstraints {
            $0.centerY.equalTo(appearanceDayLabel)
            $0.trailing.equalTo(containerView).offset(-16)
        }
        
        openingHoursLabel.snp.makeConstraints {
            $0.leading.equalTo(appearanceDayLabel)
            $0.top.equalTo(appearanceDayLabel.snp.bottom).offset(8)
            $0.height.equalTo(24)
        }
        
        openingHoursValueLabel.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.centerY.equalTo(openingHoursLabel)
        }
        
        paymentMethodLabel.snp.makeConstraints {
            $0.leading.equalTo(openingHoursLabel)
            $0.top.equalTo(openingHoursLabel.snp.bottom).offset(8)
            $0.height.equalTo(24)
        }
        
        paymentMethodStackView.snp.makeConstraints {
            $0.centerY.equalTo(paymentMethodLabel)
            $0.trailing.equalTo(containerView).offset(-16)
        }
    }
    
    func bind(viewModel: StoreDetailBaseInfoCellViewModel) {
        let data = viewModel.output.data
        
        setHeader(data.header)
        setSalesType(data.salesType?.type)
        appearanceDayStackView.bind(data.openingDays)
        paymentMethodStackView.bind(data.paymentMethods)
        setOpeningHours(data.openingHours)
    }
    
    private func setHeader(_ header: HeaderSectionResponse) {
        headerView.bind(header: header)
        
        let height = StoreDetailHeaderView.Layout.calculateHeight(header: header)
        headerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
    
    private func setSalesType(_ type: SalesType?) {
        let salesType: String
        switch type {
        case .road:
            salesType = Strings.StoreDetail.Info.SalesType.road
            
        case .store:
            salesType = Strings.StoreDetail.Info.SalesType.store
            
        case .convenienceStore:
            salesType = Strings.StoreDetail.Info.SalesType.convenienceStore
            
        default:
            salesType = "-"
        }
        
        typeValueLabel.text = salesType
    }
    
    private func setOpeningHours(_ openingHours: StoreOpeningHoursResponse?) {
        if let openingHours {
            let startDate = getStartFormattedDateString(dateString: openingHours.startTime)
            let endDate = getEndFormattedDateString(dateString: openingHours.endTime)
            
            if startDate.isEmpty && endDate.isEmpty {
                setEmptyOpeningHours()
            } else {
                openingHoursValueLabel.text = "\(startDate) \(endDate)"
                openingHoursValueLabel.textColor = Colors.gray70.color
            }
        } else {
            setEmptyOpeningHours()
        }
    }
    
    private func getStartFormattedDateString(dateString: String?) -> String {
        guard let dateString else { return "" }
        
        return DateUtils.toString(
            dateString: dateString,
            format: Strings.StoreDetail.Info.startTimeFormat,
            inputFormat: "HH:mm"
        )
    }
    
    private func getEndFormattedDateString(dateString: String?) -> String {
        guard let dateString else { return "" }
        
        return DateUtils.toString(
            dateString: dateString,
            format: Strings.StoreDetail.Info.endTimeFormat,
            inputFormat: "HH:mm"
        )
    }
    
    private func setEmptyOpeningHours() {
        openingHoursValueLabel.text = Strings.StoreDetail.Info.emptyOpeningHours
        openingHoursValueLabel.textColor = Colors.gray40.color
    }
}
