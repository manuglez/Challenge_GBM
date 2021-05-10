//
//  WebConnectionManager.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import Foundation
struct WebRequestError: Error {
    enum ErrorType {
        case ServerNotFound
        case Timeout
        case Unknown
    }
    let message: String
    let code: Int
    let type: ErrorType
}

class NetworkConnectionManager {
    typealias Attribute = String
    typealias Value = String
    typealias ServiceCallback = (_ result: Result<Int, Error>, _ data: Data?) -> Void
    
    private var stringURL: String?
    private var requestURL: URL?
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)

    init(withURLString urlString: String) {
        //requestURL = URL(string: urlString)
        stringURL = urlString
    }
    
    private var responseCallback: ServiceCallback?
    func createGETRequest(withParameters params: [Attribute:Value]) -> URLRequest?{
        dataTask?.cancel()
        if let stringURL = self.stringURL{
            guard var urlCompnent = URLComponents(string: stringURL) else {
                return nil
            }
            var keysAndValues: [String] = []
            for attr in params.keys {
                if let value = params[attr]{
                    keysAndValues.append("\(attr)=\(value)")
                }
            }
            let query = keysAndValues.joined(separator: "&")
            urlCompnent.query = query
            
            guard let url = urlCompnent.url else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        }
        
        return nil
    }
    
    func executeService(withRequest request: URLRequest, responseCallback: @escaping ServiceCallback){
        self.responseCallback = responseCallback
        dataTask = defaultSession.dataTask(with: request, completionHandler: {[weak self] data, response, error in
            print("Executed")
            defer {
                self?.dataTask = nil
            }
            
            let httpResponse = response as? HTTPURLResponse
            if let error = error {
              let errorMessage = "DataTask error: " +
                                      error.localizedDescription + "\n"
                let webError = WebRequestError(
                    message: errorMessage,
                    code: httpResponse?.statusCode ?? 0,
                    type: .Unknown)
                
                responseCallback(.failure(webError), nil)
                return
                
            } else {
                //let resulString = String(data: data, encoding: .utf8)
                //let resultDict: [AnyHashable: Any] = ["result": resulString as Any]
                responseCallback(.success(0), data)
            }
        })
        dataTask?.resume()
        
    }
}
