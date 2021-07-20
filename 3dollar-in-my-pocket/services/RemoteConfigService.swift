//
//  RemoteConfigService.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/07/18.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import FirebaseRemoteConfig
import RxSwift

protocol RemoteConfigProtocol {
  
  func fetchMinimalVersion() -> Observable<String>
}

struct RemoteConfigService: RemoteConfigProtocol {
  
  private let instance = RemoteConfig.remoteConfig()
  
  func fetchMinimalVersion() -> Observable<String> {
    return Observable.create { observer in
      self.instance.fetch(withExpirationDuration: 1800) { (status, error) in
        if status == .success {
          self.instance.activate() { (changed, error) in
            let minimumVersion = self.instance["minimum_version"].stringValue ?? ""
            
            observer.onNext(minimumVersion)
            observer.onCompleted()
          }
        } else {
          if let remoteConfigError = error {
            observer.onError(remoteConfigError)
          } else {
            observer.onError(BaseError.unknown)
          }
        }
      }
      
      return Disposables.create()
    }
  }
}
