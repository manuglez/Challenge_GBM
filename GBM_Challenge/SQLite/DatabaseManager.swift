//
//  DatabaseManager.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 07/05/21.
//

import Foundation

class DatabaseManager {
    private let sqliteQueue = DispatchQueue(label: "sqliteQueue")
    
    static let shared = DatabaseManager()
    private var db: SQLiteDB!
    private let database_name = "database.sqlite"
    private let test_database_name = "testdatabase.sqlite"
    
    private init(){
        sqliteQueue.sync{
            var dbname = database_name
            if let _ = ProcessInfo.processInfo.environment["XCTestBundlePath"] {
                dbname = test_database_name
            }
            db = SQLiteDB(databaseName: dbname)
            _ = db.createTable(query: IPCPoint.createQuery())
        }
    }
    
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
