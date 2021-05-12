//
//  GBM_ChallengeTests.swift
//  GBM_ChallengeTests
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import XCTest
@testable import GBM_Challenge

class GBM_ChallengeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIPCModels() throws {
        /*
         Test Model Initialization
         */
        var model = IPCPoint()
        model.id = 10226
        model.change = 0.817
        model.date = Date()
        model.percentageChange = 0.1832
        model.volume = 10
        model.price = 10.99
        
        XCTAssertNotNil(model)
        
        // Test Query generation
        let attrs = IPCPoint.attributes
        //attrs.remove(at: 0)
        let queryString = model.insertQuery(cols: attrs)
        XCTAssertNotEqual(queryString, "", "Bad query generation")
        
        // Test Database Insertion
        let db = DatabaseManager.shared
        
        let success = db.insert(ipc: model)
        XCTAssertTrue(success, "Model not inserted")
        
        // Test select query
        let queryResult = db.fetchAllIPC()
        XCTAssertGreaterThan(queryResult.count, 0, "Empty database")
        
        // Test Find inserted object
        XCTAssertTrue(queryResult.contains(model), "Element not found")
        
        // test Database deletion
        db.clearTableIPC()
        let queryResult2 = db.fetchAllIPC()
        XCTAssertEqual(queryResult2.count, 0, "Database not deleted")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
