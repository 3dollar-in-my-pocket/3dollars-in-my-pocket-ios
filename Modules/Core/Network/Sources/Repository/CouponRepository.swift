import Foundation

import Model

public protocol CouponRepository {
    func getMyIssuedCoupons(input: GetMyIssuedCouponsInput) async -> Result<ContentsWithCursorResponse<StoreCouponSimpleResponse>, Error>
    func issueStoreCoupon(storeId: String, couponId: String) async -> Result<StoreCouponSimpleResponse, Error>
    func useIssuedCoupon(issuedKey: String) async -> Result<String, Error>
}

public final class CouponRepositoryImpl: CouponRepository {
    public init() { }
    
    public func getMyIssuedCoupons(input: GetMyIssuedCouponsInput) async -> Result<Model.ContentsWithCursorResponse<Model.StoreCouponSimpleResponse>, any Error> {
        let request = CouponApi.getMyIssuedCoupons(input: input)
    
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func issueStoreCoupon(storeId: String, couponId: String) async -> Result<Model.StoreCouponSimpleResponse, any Error> {
        let request = CouponApi.issueStoreCoupon(storeId: storeId, couponId: couponId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func useIssuedCoupon(issuedKey: String) async -> Result<String, any Error> {
        let request = CouponApi.useIssuedCoupon(issuedKey: issuedKey)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    
}
