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
    
    func fetchMyMedals() -> Observable<[Medal]>
    
    func changeMyMedal(medalId: Int) -> Observable<User>
}

struct MedalService: MedalServiceProtocol {
    private let networkManager = NetworkManager()
    
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
    
    func fetchMyMedals() -> Observable<[Medal]> {
        let urlString = HTTPUtils.url + "/api/v1/user/medals"
        let header = HTTPUtils.defaultHeader()
        
        return self.networkManager.createGetObservable(
            class: [MedalResponse].self,
            urlString: urlString,
            headers: header
        )
        .map( { $0.map(Medal.init(response: )) })
    }
    
    func changeMyMedal(medalId: Int) -> Observable<User> {
        let urlString = HTTPUtils.url + "/api/v1/user/medal"
        let header = HTTPUtils.defaultHeader()
        let parameter: [String: Any] = ["medalId": medalId]
        
        return self.networkManager.createPutObservable(
            class: UserInfoResponse.self,
            urlString: urlString,
            headers: header,
            parameters: parameter
        )
        .map(User.init(response:))
    }
}
