//
//  VisitHistory.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/12.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct VisitHistory {
    let createdAt: String
    let storeId: Int
    let store: Store
    let type: VisitType
    let user: User
    let visitHistoryId: Int
    
    init(response: VisitHistoryWithUserResponse) {
        self.createdAt = response.createdAt
        self.storeId = response.storeId
        self.store = Store()
        self.type = response.type
        self.user = User(response: response.user)
        self.visitHistoryId = response.visitHistoryId
    }
    
    init(response: VisitHistoryWithStoreResponse) {
        self.createdAt = response.createdAt
        self.storeId = response.store.storeId
        self.store = Store(response: response.store)
        self.type = response.type
        self.user = User()
        self.visitHistoryId = response.visitHistoryId
    }
}

extension VisitHistory: Equatable {
    static func == (lhs: VisitHistory, rhs: VisitHistory) -> Bool {
        return lhs.visitHistoryId == rhs.visitHistoryId
    }
}
