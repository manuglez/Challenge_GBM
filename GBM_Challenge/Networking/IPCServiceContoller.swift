//
//  WebServicesController.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import Foundation

class IPCServiceContoller: WebServiceCaller {
    var baseUrl: String {
        return "https://run.mocky.io/v3/cc4c350b-1f11-42a0-a1aa-f8593eafeb1e"
    }
    
    //private let baseUrl = "https://run.mocky.io/v3/cc4c350b-1f11-42a0-a1aa-f8593eafeb1e"
    
    /// Singleton object if the controller
    static let shared = IPCServiceContoller()
    
    /// prevents to call the initializer from outside the class
    private init(){}
    
    /// makes the request to the IPC data service.
    /// Calls the implementation of the WebServiceCaller protocol
    ///
    /// - Parameters:
    ///     - ipcCallback: closure that receives the data from the service.

    func ipcRequest(ipcCallback: @escaping (Bool, [IPCPoint]?) -> Void) {
        makeRequest { sucess, data in
            if sucess {
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    //2020-08-18T00:02:43.933-05:00
                    dateFormatter.dateFormat = IPCPoint.dateFormat
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    let ipcData = try decoder.decode([IPCPoint].self, from: data)
                    ipcCallback(true, ipcData)
                } catch (let jsonError){
                    print(jsonError)
                    print(jsonError.localizedDescription)
                    ipcCallback(false, nil)
                }
            }
        }
    }
    
    //MARK: - WebServiceCaller Delegate
    /// Implementation of the WebServiceCaller protocol that makes the services call
    ///
    /// - Parameters:
    ///     - ipcCallback: closure that receives the data from the service.
    func makeRequest(resultCallback: @escaping (Bool, Data) -> Void) {
        let netMng = NetworkConnectionManager(withURLString: baseUrl)
        if let request = netMng.createGETRequest(withParameters: [:]) {
            netMng.executeService(withRequest: request, responseCallback: {result, data in
                switch result{
                case .success(let flag):
                    print("Success \(flag)")
                    //resultCallback(true, dictionaryData)
                    if let _d = data{
                        resultCallback(true, _d)
                        
                    }
                    break
                case .failure(let error):
                    print("Failure \(error.localizedDescription)")
                    //resultCallback(false, nil)
                    break
                }
                
            })
        }
    }
}
