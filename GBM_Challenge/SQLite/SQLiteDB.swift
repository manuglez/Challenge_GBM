//
//  SQLiteDB.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 07/05/21.
//

import Foundation

class SQLiteDB {
    private var databaseURL: URL?
    private var dbPointer: OpaquePointer?
    init(databaseName dbname: String) {
        let fileManager = FileManager.default
        do {
            let baseUrl = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            databaseURL = baseUrl.appendingPathComponent(dbname)
            if let dbURL = databaseURL {
                var pointer: OpaquePointer? = nil
                let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
                let status = sqlite3_open_v2(dbURL.absoluteString.cString(using: .utf8), &pointer, flags, nil)
                if status == SQLITE_OK {
                    print("DB Created")
                    self.dbPointer = pointer
                }
            }
        } catch {
            print(error)
        }
    }
    
    func createTable(query createQuery: String) -> Bool{
        if let dbPointer = dbPointer {
            let errMsg: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
            if sqlite3_exec(dbPointer, createQuery, nil, nil, errMsg) == SQLITE_OK {
                print("Table Created")
                return true
            } else {
                print("Failed to crate table")
            }
        }
        return false
    }
    
    
    func insert(query insertQuery: String) -> Bool{
        var success = false
        if let dbPointer = dbPointer {
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(dbPointer, insertQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Record inserted")
                    success =  true
                }
            } else {
                print("Insert query prepare error")
            }
            
            sqlite3_finalize(statement)
        }
        return success
    }
    
    func select(query selectQuery: String) -> [[String: Any]]{
        var resultDictionary: [[String: Any]] = []
        if let dbPointer = dbPointer {
            var selectStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(dbPointer, selectQuery, -1, &selectStatement, nil) == SQLITE_OK {
                while sqlite3_step(selectStatement) == SQLITE_ROW {
                    var rowDictionary: [String: Any] = [:]
                    let column_count = sqlite3_column_count(selectStatement)
                    
                    for col in 0...column_count-1 {
                        let column_name = getCCharText(sqlite3_column_name(selectStatement, col))
                        
                        switch sqlite3_column_type(selectStatement, col) {
                        case SQLITE_INTEGER:
                            let i = Int(sqlite3_column_int(selectStatement, col))
                            rowDictionary[column_name] = i
                            break
                        case SQLITE_FLOAT:
                            let f = sqlite3_column_double(selectStatement, col)
                            rowDictionary[column_name] = f
                            break
                        case SQLITE_BLOB:
                            if let blob = sqlite3_column_blob(selectStatement, col){
                                let length = sqlite3_column_bytes(selectStatement, col)
                                let data = Data(bytes: blob, count: Int(length))
                                rowDictionary[column_name] = data
                            }
                            break
                        case SQLITE_TEXT,
                             SQLITE3_TEXT:
                            let t = getUInt8Text(sqlite3_column_text(selectStatement, col))
                            rowDictionary[column_name] = t
                            break
                        case SQLITE_NULL:
                            break
                        default:
                            break
                        }
                    }
                    resultDictionary.append(rowDictionary)
                }
            }
            sqlite3_finalize(selectStatement)
        }
        
        return resultDictionary
    }
    
    func delete(from tableName: String, where conditionDictionary: [String: SQLiteDataType]?) -> Bool{
        if let dbPointer = dbPointer {
            var whereCondition = ""
            if let conditions = conditionDictionary {
                whereCondition = "WHERE "
                var conditionsStrings: [String] = []
                for attr in conditions.keys {
                    conditionsStrings.append("\(attr) = \(conditions[attr]?.queryValue() ?? "")")
                }
                whereCondition.append(conditionsStrings.joined(separator: ", "))
            }
            let deleteQuery = "DELETE FROM " + tableName + whereCondition
            var deleteStatement: OpaquePointer?
            defer {
                sqlite3_finalize(deleteStatement)
            }
              if sqlite3_prepare_v2(dbPointer, deleteQuery, -1, &deleteStatement, nil) ==
                  SQLITE_OK {
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                  print("Row deleted")
                    return true
                } else {
                  print("Error deleting row")
                }
              } else {
                print("ERROR on delete prepare")
              }
        }
        
        return false
    }
    
    private func getCCharText(_ cText: UnsafePointer<CChar>) -> String{
        let text = UnsafePointer<CChar>?(cText)
        let string = text != nil ? String(cString: text!) : "(nil)"
        return string
    }
    
    private func getUInt8Text(_ cText: UnsafePointer<UInt8>) -> String{
        let text = UnsafePointer<UInt8>?(cText)
        let string = text != nil ? String(cString: text!) : "(nil)"
        return string
    }
}
