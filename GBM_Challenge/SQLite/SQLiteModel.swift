//
//  SQLiteModel.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 07/05/21.
//

import Foundation

protocol SQLiteModel {
    static var tableName: String { get }
    static var attributes: [String] { get }
    
    static func createQuery() -> String
    //static func insertQuery<T: SQLiteDataType>(columns: [String], values: [T]) -> String?
    func insertQuery(cols dict: [String]) -> String?
    static func selectAllQuery() -> String
    static var deleteQuery: String { get }
}

protocol SQLiteDataType {
    func queryValue() -> String
}

extension Int: SQLiteDataType{
    func queryValue() -> String {
        return "\(self)"
    }
}

extension UInt: SQLiteDataType{
    func queryValue() -> String {
        return "\(self)"
    }
}

extension String: SQLiteDataType{
    func queryValue() -> String {
        return "'\(self)'"
    }
}
extension Double: SQLiteDataType{
    func queryValue() -> String {
        return "\(self)"
    }
}
extension Date: SQLiteDataType{
    func queryValue() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let dateString = formatter.string(from: self)
        return "'\(dateString)'"
    }
}
extension Data: SQLiteDataType{
    func queryValue() -> String {
        let dataString = String(data: self, encoding: .utf8) ?? ""
        return "'\(dataString)'"
    }
    
}
extension Bool: SQLiteDataType{
    func queryValue() -> String {
        return "\(self ? 1 : 0)"
    }
}
extension Float: SQLiteDataType{
    func queryValue() -> String {
        return "\(self)"
    }
}
