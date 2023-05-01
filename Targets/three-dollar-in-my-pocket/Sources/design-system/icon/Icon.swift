//
//  Icon.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2022/11/18.
//  Copyright © 2022 Macgongmon. All rights reserved.
//

import UIKit

struct Icon {
    struct Check {
        enum Style {
            case solid
            case line
        }
                
        static func generate(isOn: Bool, style: Style) -> UIImage? {
            switch style {
            case .solid:
                if isOn {
                    return UIImage(named: "ic_check_solid_on")
                } else {
                    return UIImage(named: "ic_check_solid_off")
                }
                
            case .line:
                if isOn {
                    return UIImage(named: "ic_check_line_on")
                } else {
                    return UIImage(named: "ic_check_line_off")
                }
            }
        }
    }
}
