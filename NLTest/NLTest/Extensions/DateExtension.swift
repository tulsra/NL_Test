//
//  DateExtension.swift
//  NLTest
//
//  Created by Tulasi on 01/08/19.
//  Copyright © 2019 Assignment. All rights reserved.
//

import Foundation

extension Date {
    
    var displayDate: String {
        get {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd-MM-yyyy"
            return dateFormatterPrint.string(from: self)
        }
    }
    
}

extension Int {
    var date: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(self))
        }
    }
}
