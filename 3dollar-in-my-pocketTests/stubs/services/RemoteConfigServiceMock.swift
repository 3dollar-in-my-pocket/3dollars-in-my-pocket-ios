//
//  RemoteConfigService.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/07/20.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import 가슴속3천원_debug

struct RemoteConfigServiceMock: RemoteConfigProtocol {
  
  func fetchMinimalVersion() -> Observable<String> {
    return Observable.create { observer in
      observer.onNext("1.0.0")
      observer.onCompleted()
      
      return Disposables.create()
    }
  }
}
