//
//  SQLiteDB.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 07/05/21.
//

import Foundation

/// Manages directly all the database access directly
class SQLiteDB {
    /// URL where database is stored
    private var databaseURL: URL?
    
    ///Global pointer to access the database
    private var dbPointer: OpaquePointer?
    
    /// Database initialitation.
    init(databaseName dbname: String) {
        let fileManager = FileManager.default
        do {
            sqlite3_shutdown();
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
                } else {
                    print("unable to open database")
                }
            }
        } catch {
            print(error)
        }
    }
    
    /// Crates a table on the database from a query string
    ///
    /// - Parameters:
    ///     - createQuery: The table create query srring
    ///
    ///     - Returns: A bolean indicating the Table Create was successfull
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
    
    /// Inserts a row to a table in the databasethe database from a query string
    ///
    /// - Parameters:
    ///     - insertQuery: The table Insert query string
    ///
    ///     - Returns: A bolean indicating the insert was successfull
    func insert(query insertQuery: String) -> Bool{
        var success = false
        if let dbPointer = dbPointer {
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(dbPointer, insertQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    success =  true
                }
            } else {
                print("Insert query prepare error")
            }
            
            sqlite3_finalize(statement)
        }
        return success
    }
    
    /// Selects data in the  database from a query string
    ///
    /// - Parameters:
    ///     - selectQuery: The table Select query string
    ///
    ///     - Returns: A dictionary Array with the data
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
    
    /// Deletes data in the  database from a query string
    ///
    /// - Parameters:
    ///     - selectQuery: The Delete query string
    ///     - conditionDictionary: A dictionary with the conditions that perdorm the deletion. Can be nil to delete all the data in the table
    ///
    ///     - Returns: A boolean indicating the deletion was successfull
    func delete(from tableName: String, where conditionDictionary: [String: SQLiteDataType]?) -> Bool{
        var returnValue = false
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
          
              if sqlite3_prepare_v2(dbPointer, deleteQuery, -1, &deleteStatement, nil) ==
                  SQLITE_OK {
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                  print("Row deleted")
                    returnValue = true
                } else {
                  print("Error deleting row")
                }
              } else {
                print("ERROR on delete prepare")
              }
            sqlite3_finalize(deleteStatement)
        }
        
        return returnValue
    }
    
    /// String to represent a C Text value in SQLite
    private func getCCharText(_ cText: UnsafePointer<CChar>) -> String{
        let text = UnsafePointer<CChar>?(cText)
        let string = text != nil ? String(cString: text!) : "(nil)"
        return string
    }
    
    /// String to represent a UInt Text value in SQLite
    private func getUInt8Text(_ cText: UnsafePointer<UInt8>) -> String{
        let text = UnsafePointer<UInt8>?(cText)
        let string = text != nil ? String(cString: text!) : "(nil)"
        return string
    }
}
