//
//  LocationError.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

import Common

enum LocationError: LocalizedError {
    
    case denied
    case unknown
    case unknownLocation
    case disableLocationService
    
    var localizedDescription: String {
        switch self {
        case .denied:
            return "location_deny_description".localized
        case .unknown:
            return "error_unknown".localized
        case .unknownLocation:
            return "location_unknown_description".localized
        case .disableLocationService:
            return "error_location_permission_denied_message".localized
        }
    }
}

extension Common.LocationError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return "location_deny_description".localized
        case .unknown:
            return "error_unknown".localized
        case .unknownLocation:
            return "location_unknown_description".localized
        case .disableLocationService:
            return "error_location_permission_denied_message".localized
        }
    }
}
