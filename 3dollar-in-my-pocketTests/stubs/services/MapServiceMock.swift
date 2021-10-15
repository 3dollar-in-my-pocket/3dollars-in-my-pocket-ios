//
//  MapServiceMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import dollar_in_my_pocket

struct MapServiceMock: MapServiceProtocol {
  var getAddressFromLocationObservable: Observable<String>?
  var searchAddressObservable: Observable<LocalResponse<PlaceDocument>>?
  var getCurrentAddressObservable: Observable<LocalResponse<AddressDocument>>?
  
  func getAddressFromLocation(lat: Double, lng: Double) -> Observable<String> {
    return self.getAddressFromLocationObservable ??
      .error(CommonError(desc: "getAddressFromLocationObservable가 정의되지 않았습니다."))
  }
  
  func searchAddress(keyword: String) -> Observable<LocalResponse<PlaceDocument>> {
    return self.searchAddressObservable ??
      .error(CommonError(desc: "searchAddressObservable가 정의되지 않았습니다."))
  }
  
  func getCurrentAddress(lat: Double, lng: Double) -> Observable<LocalResponse<AddressDocument>> {
    return self.getCurrentAddressObservable ??
      .error(CommonError(desc: "getCurrentAddressObservable가 정의되지 않았습니다."))
  }
}
