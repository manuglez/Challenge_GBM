//
//  DateExtensions.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 09/05/21.
//

import Foundation

extension Date {
    func dateString(withFormat dateFormat: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
    
}

extension String {
    func stringToDate(withFormat dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
}
