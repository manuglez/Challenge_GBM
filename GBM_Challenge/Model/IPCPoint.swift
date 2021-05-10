//
//  IPCPoint.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 09/05/21.
//

import Foundation

struct IPCPoint: Codable {
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    
    var id: Int? = 0
    var date: Date = Date()
    var price: Double
    var percentageChange: Double
    var volume: Int
    var change: Double
    
    init(fromDictionary dict: Dictionary<String, Any>){
        self.id = dict[IPCPoint.idAttribute] as? Int ?? 0
        if let dateString = dict[IPCPoint.dateAttribute] as? String{
            self.date = dateString.stringToDate(withFormat: IPCPoint.dateFormat) ?? Date()
        }
        self.price = dict[IPCPoint.priceAttribute] as? Double ?? 0.0
        self.percentageChange = dict[IPCPoint.percentageChangeAttribute] as? Double ?? 0.0
        self.volume = dict[IPCPoint.volumeAttribute] as? Int ?? 0
        self.change = dict[IPCPoint.changeAttribute] as? Double ?? 0.0
    }
}

// extension for SQL processing
extension IPCPoint: SQLiteModel {
    static var tableName: String {
        return "IPCPoint"
    }
    
    static var attributes: [String] {
        return [idAttribute, dateAttribute, priceAttribute, percentageChangeAttribute, volumeAttribute, changeAttribute]
    }
    
    static func createQuery() -> String {
        "CREATE TABLE IF NOT EXISTS \(tableName) (\(idAttribute) INTEGER PRIMARY KEY AUTOINCREMENT, \(dateAttribute) TEXT, \(priceAttribute) FLOAT, \(percentageChangeAttribute) FLOAT, \(volumeAttribute) INTEGER , \(changeAttribute) FLOAT);"
    }
    
    static var deleteQuery: String{
        return "DELETE FROM " + tableName
    }
    //static func insertQuery<T: SQLiteDataType>(columns: [String], values: [T]) -> String? {
    func insertQuery(cols dict: [String]) -> String? {
        var columns: [String] = []
        var values: [String] = []
        
        if dict.contains(IPCPoint.dateAttribute) {
            columns.append(IPCPoint.dateAttribute)
            values.append("'\(self.date.dateString(withFormat: IPCPoint.dateFormat))'")
        }
        
        if dict.contains(IPCPoint.priceAttribute) {
            columns.append(IPCPoint.priceAttribute)
            values.append("\(self.price)")
        }
        
        if dict.contains(IPCPoint.percentageChangeAttribute) {
            columns.append(IPCPoint.percentageChangeAttribute)
            values.append("\(self.percentageChange)")
        }
        
        if dict.contains(IPCPoint.volumeAttribute) {
            columns.append(IPCPoint.volumeAttribute)
            values.append("\(self.volume)")
        }
        
        if dict.contains(IPCPoint.changeAttribute) {
            columns.append(IPCPoint.changeAttribute)
            values.append("\(self.change)")
        }
        
        let colsQuery = columns.joined(separator: ", ")
        let valueQuery = values.joined(separator: ", ")
        
        if columns.count > 0 && values.count > 0 {
            let query = "INSERT INTO \(IPCPoint.tableName) (\(colsQuery)) VALUES (\(valueQuery))"
            return query
        }
        return nil
    }
    
    static func selectAllQuery() -> String {
        return "SELECT * FROM " + tableName
    }
    
    static let idAttribute = "id"
    static let dateAttribute = "date"
    static let priceAttribute = "price"
    static let percentageChangeAttribute = "percentageChange"
    static let volumeAttribute = "volume"
    static let changeAttribute = "change"
}
