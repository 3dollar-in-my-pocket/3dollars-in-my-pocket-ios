//
//  VisitHistoryService.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/12.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Alamofire
import RxSwift

protocol VisitHistoryProtocol {
  
  func visitStore(storeId: Int, type: VisitType) -> Observable<String>
}

struct VisitHistoryService: VisitHistoryProtocol {
  
  func visitStore(storeId: Int, type: VisitType) -> Observable<String> {
    let addVisitHistoryRequest = AddVisitHistoryRequest(storeId: storeId, type: type)
    
    return Observable.create { observer in
      let urlString = HTTPUtils.url + "/api/v2/store/visit"
      let headers = HTTPUtils.defaultHeader()
      let parameters = addVisitHistoryRequest.params
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .post,
        parameters: parameters,
        encoding: JSONEncoding.default,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: String.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
}
