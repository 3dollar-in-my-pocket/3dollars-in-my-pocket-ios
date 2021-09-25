//
//  LocationError.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

enum LocationError: LocalizedError {
    
    case denied
    case unknown
    case unknownLocation
    case disableLocationService
    
    var localizedDescription: String {
        switch self {
        case .denied:
            return R.string.localization.location_deny_description()
        case .unknown:
            return R.string.localization.error_unknown()
        case .unknownLocation:
            return R.string.localization.location_unknown_description()
        case .disableLocationService:
            return R.string.localization.error_location_permission_denied_message()
        }
    }
}
