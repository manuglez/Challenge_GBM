//
//  IPCController.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 09/05/21.
//

import Foundation

protocol IPCModelDelegate: AnyObject {
    func ipcDataFetched(_ points: [IPCPoint])
}

protocol IPCViewModelDelegate: AnyObject {
    func ipcDataFetched(_ points: [IPCViewModel])
}

class IPCController {
    weak var modelDelegate: IPCModelDelegate?
    weak var viewModelDelegate: IPCViewModelDelegate?
    
    func fetchAllDataPoints() {
        let db = DatabaseManager.shared
        let ipcData = db.fetchAllIPC()
        if ipcData.count == 0 {
            fetchDataFromService()
        } else {
            sendDataToDelegate(ipcData)
        }
    }
    
    func fetchDataFromService() {
        let service = IPCServiceContoller.shared
        service.ipcRequest { success, points in
            if let _p = points {
                let db = DatabaseManager.shared
                db.clearTableIPC()
                for point in _p {
                    _ = db.insert(ipc: point)
                }
                self.sendDataToDelegate(_p)
            }
        }
    }
    
    private func sendDataToDelegate(_ ipcPoints: [IPCPoint]) {
        DispatchQueue.main.async {
            self.modelDelegate?.ipcDataFetched(ipcPoints)
        }
        
        if let vmDelegate = self.viewModelDelegate {
            var viewModelData: [IPCViewModel] = []
            for ipc in ipcPoints {
                viewModelData.append(IPCViewModel(withModel: ipc))
            }
            DispatchQueue.main.async {
                vmDelegate.ipcDataFetched(viewModelData)
            }
        }
    }
}
