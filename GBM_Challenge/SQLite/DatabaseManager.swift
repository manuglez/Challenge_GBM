//
//  DatabaseManager.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 07/05/21.
//

import Foundation

class DatabaseManager {
    /// All database access are performed in the same thrade
    private let sqliteQueue = DispatchQueue(label: "sqliteQueue")
    
    /// SIngleton instance of the class
    static let shared = DatabaseManager()
    
    /// Instance to the SQLite class
    private var db: SQLiteDB!
    
    /// Database name
    private let database_name = "database.sqlite"
    
    /// Database name for XCTest executions
    private let test_database_name = "testdatabase.sqlite"
    
    /// Controller Initializaton
    private init(){
        sqliteQueue.sync{
            var dbname = database_name
            /// Use a differente database name if it is execiting Unit Tests
            if let _ = ProcessInfo.processInfo.environment["XCTestBundlePath"] {
                dbname = test_database_name
            }
            db = SQLiteDB(databaseName: dbname)
            _ = db.createTable(query: IPCPoint.createQuery())
        }
    }
    
    /// Inserts the IPCPoint object model to the database
    ///
    /// - Parameters:
    ///     - ipc: The IPCPoint object.
    ///
    ///     - Returns: A boolean if insertion was successfull
    func insert(ipc: IPCPoint) -> Bool{
        var attrs = IPCPoint.attributes
        attrs.remove(at: 0)
        if let query = ipc.insertQuery(cols: attrs)
        {
            var returnValue = false
            sqliteQueue.sync{
                returnValue = db.insert(query: query)
            }
            return returnValue
        }
        return false
    }
    
    /// Inserts the IPCPoint object model to the database
    ///
    /// - Parameters:
    ///     - ipc: The IPCPoint object.
    ///
    ///     - Returns: A boolean if insertion was successfull
    func fetchAllIPC() -> [IPCPoint]{
        var allIPC: [IPCPoint] = []
        let selectQuery = IPCPoint.selectAllQuery()
        var resultOp:  [[String : Any]]?
        sqliteQueue.sync{
            resultOp = db.select(query: selectQuery)
        }
        if let result = resultOp {
            print(result)
            for row in result {
                allIPC.append(IPCPoint(fromDictionary: row))
            }
        }
        return allIPC
    }
    
    /// - Clears all the data in the IPC table
    func clearTableIPC() {
        var deleteSuccess = false
        sqliteQueue.sync{
            deleteSuccess = db.delete(from: IPCPoint.tableName, where: nil)
        }
        
        if deleteSuccess {
            print("Clear IPC success")
        }
    }
}
