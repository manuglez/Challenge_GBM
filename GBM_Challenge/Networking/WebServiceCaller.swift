//
//  WebServiceCaller.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import Foundation
protocol WebServiceCaller {
    var baseUrl: String { get }
    
    func makeRequest(resultCallback: @escaping (_ success: Bool, _ data: Data) -> Void)
    
}
