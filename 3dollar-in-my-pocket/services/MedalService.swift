//
//  MedalService.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/12/11.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Alamofire
import RxSwift

protocol MedalServiceProtocol {
    func fetchMedals() -> Observable<[MedalResponse]>
    
    func fetchMyMedals() -> Observable<[MedalResponse]>
}

struct MedalService: MedalServiceProtocol {
    func fetchMedals() -> Observable<[MedalResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/medals"
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: [MedalResponse].self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMyMedals() -> Observable<[MedalResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/user/medals"
            let header = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: header
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: [MedalResponse].self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
