import UIKit
import Combine

import Common
import DesignSystem
import Model
import Networking
import Log

final class BossStoreCouponBottomSheetViewModel: BaseViewModel {
    struct Input {
        let didTapUseCoupon = PassthroughSubject<Void, Never>()
        let useCoupon = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let showConfirmAlert = PassthroughSubject<Void, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let errorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        let couponViewModel: BossStoreCouponViewModel
        
        let reloadCouponList = PassthroughSubject<Void, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let storeId: String
        let coupon: StoreCouponSimpleResponse
    }
    
    let input = Input()
    let output: Output
    private let couponRepository: CouponRepository
    private let logManager: LogManagerProtocol
    private let config: Config
    
    init(
        config: Config,
        couponRepository: CouponRepository = CouponRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.logManager = logManager
        self.couponRepository = couponRepository
        
        let viewModel = BossStoreCouponViewModel(config: .init(storeId: config.storeId, data: config.coupon, sourceType: .useCoupon))
        self.output = Output(couponViewModel: viewModel)
    }
    
    override func bind() {
        input.didTapUseCoupon
            .withUnretained(self)
            .sink { (owner: BossStoreCouponBottomSheetViewModel, _) in
                owner.output.showConfirmAlert.send()
            }
            .store(in: &cancellables)
        
        input.useCoupon
            .withUnretained(self)
            .sink { (owner: BossStoreCouponBottomSheetViewModel, _) in
                owner.useCoupon()
            }
            .store(in: &cancellables)
    }
    
    private func useCoupon() {
        guard let issuedKey = config.coupon.issued?.issuedKey else { return }
        
        output.showLoading.send(true)
        Task {
            let result = await couponRepository.useIssuedCoupon(issuedKey: issuedKey)
            
            switch result {
            case .success:
                output.showLoading.send(false)
                output.showToast.send("쿠폰을 사용했어요!")
                output.route.send(.dismiss)
            case .failure(let error):
                output.showLoading.send(false)
                output.errorAlert.send(error)
            }
        }
    }
}
