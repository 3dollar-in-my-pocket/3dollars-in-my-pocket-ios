//
//  VisitOverview.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/18.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct VisitOverview: Equatable {
    var existsCounts: Int
    var isCertified: Bool
    var notExistsCounts: Int
    
    
    init() {
        self.existsCounts = 0
        self.isCertified = false
        self.notExistsCounts = 0
    }
    
    init(response: VisitHistoryCountsResponse) {
        self.existsCounts = response.existsCounts
        self.isCertified = response.isCertified
        self.notExistsCounts = response.notExistsCounts
    }
}
