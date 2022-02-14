//
//  StoreCellType.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2022/02/06.
//  Copyright © 2022 Macgongmon. All rights reserved.
//

import Foundation

enum StoreCellType: Equatable {
    static func == (lhs: StoreCellType, rhs: StoreCellType) -> Bool {
        switch (lhs, rhs) {
        case (.store(let store1), .store(let store2)):
            return store1.storeId == store2.storeId
            && store1.visitHistory.isCertified == store2.visitHistory.isCertified
            
        case (.advertisement(let ad1), .advertisement(let ad2)):
            return ad1.id == ad2.id
            
        case (.empty, .empty):
            return true
            
        default:
            return false
        }
    }
    
    case store(Store)
    case advertisement(Popup)
    case empty
    
    var value: Any? {
        switch self {
        case .store(let store):
            return store
            
        case .advertisement(let advertisement):
            return advertisement
            
        case .empty:
            return nil
        }
    }
}
