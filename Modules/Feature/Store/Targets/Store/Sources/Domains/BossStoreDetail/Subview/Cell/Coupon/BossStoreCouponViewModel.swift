import UIKit
import Combine

import Networking
import Model
import Common
import Log

final class BossStoreCouponViewModel: BaseViewModel {
    enum CouponStatus {
        case issuable
        case issued
        case used
        case expired
    }
    
    enum SourceType {
        case storeDetail
        case useCoupon
        case myCoupons
    }
    
    struct Input {
        let didTapRightButton = PassthroughSubject<Void, Never>()
        let didTapStoreView = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let date: String
        let deadline: String?
        let couponStatus: CurrentValueSubject<CouponStatus, Never>
        let isRightViewHidden: Bool
        let store: PlatformStore?
        let fromMyCoupons: Bool
        
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let moveToUseCoupon = PassthroughSubject<StoreCouponSimpleResponse, Never>()
        let moveToStoreDetail = PassthroughSubject<String, Never>()
    }
    
    struct Config {
        let storeId: String
        let data: StoreCouponSimpleResponse
        let sourceType: SourceType
    }

    let input = Input()
    let output: Output
    let config: Config
    
    private var coupon: StoreCouponSimpleResponse
    private let logManager: LogManagerProtocol
    private let couponRepository: CouponRepository
    
    init(
        config: Config,
        logManager: LogManagerProtocol = LogManager.shared,
        couponRepository: CouponRepository = CouponRepositoryImpl()
    ) {
        self.config = config
        
        let data = config.data
        let startDate = data.validityPeriod.startDateTime.toDate()?.toString(format: "yyyy.MM.dd") ?? ""
        let endDate = data.validityPeriod.endDateTime.toDate()?.toString(format: "yyyy.MM.dd") ?? ""
        let deadline = data.validityPeriod.endDateTime.toDate()?.remainingDaysString()
        let couponStatus: CouponStatus = {
            guard let issued = data.issued else {
                return .issuable
            }
            
            switch issued.status {
            case .active: return .issued
            case .used: return .used
            case .expired: return .expired
            default: return .issued
            }
        }()
        
        let store: PlatformStore? = {
            guard let storeResponse = config.data.store else { return nil }
           
            return PlatformStore(response: storeResponse)
        }()
        
        self.output = Output(
            title: config.data.name,
            date: "\(startDate) ~ \(endDate)",
            deadline: deadline,
            couponStatus: .init(couponStatus),
            isRightViewHidden: config.sourceType == .useCoupon,
            store: store,
            fromMyCoupons: config.sourceType == .myCoupons
        )
        
        self.logManager = logManager
        self.couponRepository = couponRepository
        self.coupon = config.data
        
        super.init()
    }

    override func bind() {
        super.bind()
        
        let issueCoupon = input.didTapRightButton
            .withUnretained(self)
            .filter { owner, _ in owner.output.couponStatus.value == .issuable }
            .share()
        
        let useCoupon = input.didTapRightButton
            .withUnretained(self)
            .filter { owner, _ in owner.output.couponStatus.value == .issued }
            .share()
        
        issueCoupon
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.couponRepository.issueStoreCoupon(
                    storeId: owner.config.storeId,
                    couponId: owner.coupon.couponId
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let data):
                    owner.output.showToast.send("쿠폰을 발급받았어요!")
                    owner.output.couponStatus.send(.issued)
                    owner.coupon = data
                case .failure(let error):
                    owner.output.showToast.send(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        
        useCoupon
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.moveToUseCoupon.send(owner.coupon)
            }
            .store(in: &cancellables)
        
        input.didTapStoreView
            .withUnretained(self)
            .sink { owner, _ in
                guard let storeId = owner.coupon.store?.storeId else { return }
                owner.output.moveToStoreDetail.send(storeId)
            }
            .store(in: &cancellables)
    }
}

extension BossStoreCouponViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreCouponViewModel: Hashable {
    static func == (lhs: BossStoreCouponViewModel, rhs: BossStoreCouponViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Log
private extension BossStoreCouponViewModel {
    
}
