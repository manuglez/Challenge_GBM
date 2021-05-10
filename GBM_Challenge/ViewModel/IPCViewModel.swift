//
//  IPCViewModel.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 09/05/21.
//

import Foundation

struct IPCViewModel{
    var date: Date
    var price: Double
    
    init(withModel model: IPCPoint){
        self.date = model.date
        self.price = model.price
    }
}
