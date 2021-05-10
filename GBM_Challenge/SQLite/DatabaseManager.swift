//
//  DatabaseManager.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 07/05/21.
//

import Foundation

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let db: SQLiteDB!
    private let database_name = "database.sqlite"
    
    private init(){
        db = SQLiteDB(databaseName: database_name)
        _ = db.createTable(query: IPCPoint.createQuery())
    }
    
    func insert(ipc: IPCPoint) -> Bool{
        var attrs = IPCPoint.attributes
        attrs.remove(at: 0)
        if let query = ipc.insertQuery(cols: attrs)
        {
            return db.insert(query: query)
        }
        return false
    }
    
    func fetchAllIPC() -> [IPCPoint]{
        var allIPC: [IPCPoint] = []
        let selectQuery = IPCPoint.selectAllQuery()
        let result = db.select(query: selectQuery)
        
        print(result)
        for row in result {
            allIPC.append(IPCPoint(fromDictionary: row))
        }
        
        return allIPC
    }
    
    func clearTableIPC() {
        let deleteSuccess = db.delete(from: IPCPoint.tableName, where: nil)
        if deleteSuccess {
            print("Clear IPC success")
        }
    }
}
