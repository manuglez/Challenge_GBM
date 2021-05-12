//
//  WebConnectionManager.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import Foundation
/// Struct that manages an Error during web connections
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

/// Manages directly all the web connections to consume services.
class NetworkConnectionManager {
    typealias Attribute = String
    typealias Value = String
    /// A closure declaration of the service responces
    typealias ServiceCallback = (_ result: Result<Int, Error>, _ data: Data?) -> Void
    
    /// The  URL string and instance of the service
    private var stringURL: String?
    private var requestURL: URL?
    
    ///the URLSessionDataTask that performs the service consumption
    var dataTask: URLSessionDataTask?
    
    /// The default URL Session that manages the connection with the service
    let defaultSession = URLSession(configuration: .default)

    /// Initializarion of the manager with an URL String
    init(withURLString urlString: String) {
        //requestURL = URL(string: urlString)
        stringURL = urlString
    }
    
    /// The callback that sends all the response data to the caller object
    private var responseCallback: ServiceCallback?
    
    /// Creates a URLRequest with defualt configurations and GET method
    ///
    /// - Parameters:
    ///     - params: A Dictionary with all the parameters of the service to include in the URLRequest
    ///
    ///     - Returns: The URL Request object
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
    
    /// Executes the web service from an URL Request
    ///
    /// - Parameters:
    ///     - request: The URLRequest to perform the service
    ///     - responseCallback: A closuse that receives the Data of the service response
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
                responseCallback(.success(0), data)
            }
        })
        dataTask?.resume()
        
    }
}
