//
//  StoreCellType.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2022/02/06.
//  Copyright © 2022 Macgongmon. All rights reserved.
//

import Foundation

enum StoreCellType {
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
