//
//  DateExtension.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/12.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

extension Date {
  
  func toString(format: String) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale.current
    dateFormatter.timeZone = TimeZone.current
    
    return dateFormatter.string(from: self)
  }
  
  func addWeek(week: Int) -> Date {
    return Calendar.current.date(byAdding: .weekOfYear, value: week, to: self) ?? Date()
  }
}
