//
//  StreetFoodStoreDetailSection.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2022/10/02.
//  Copyright © 2022 Macgongmon. All rights reserved.
//

import Foundation

enum StreetFoodStoreDetailSection: Int {
    case overview
    case visitHistory
    case info
    case menus
    case photos
    case reviewAndadvertisement
    case unknown
    
    init(sectionIndex: Int) {
        switch sectionIndex {
        case 0:
            self = .overview
            
        case 1:
            self = .visitHistory
            
        case 2:
            self = .info
            
        case 3:
            self = .menus
            
        case 4:
            self = .photos
            
        case 5:
            self = .reviewAndadvertisement
            
        default:
            self = .unknown
        }
    }
}
