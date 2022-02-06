//
//  BaseReactor.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2022/01/01.
//  Copyright © 2022 Macgongmon. All rights reserved.
//

import RxCocoa

class BaseReactor {
    let showErrorAlertPublisher = PublishRelay<Error>()
    let openURLPublisher = PublishRelay<String>()
    let showLoadingPublisher = PublishRelay<Bool>()
}
