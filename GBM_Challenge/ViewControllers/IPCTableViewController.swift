//
//  IPCTableViewController.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import UIKit

class IPCTableViewController: UITableViewController, IPCModelDelegate {
    let cellIdentifier = "cellIdetifier"
    
    var modelData: [IPCPoint] = []
    var ipcCpntroller = IPCController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipcCpntroller.modelDelegate = self
        ipcCpntroller.fetchAllDataPoints()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return modelData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return modelData[section].date.dateString(withFormat: "dd 'de' MMM 'de' yyyy', 'HH:mm:ss")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let model = modelData[indexPath.section]
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Precio"
            cell.detailTextLabel?.text = String(describing: model.price)
        case 1:
            cell.textLabel?.text = "% Cambio"
            cell.detailTextLabel?.text = String(describing: model.percentageChange)
        case 2:
            cell.textLabel?.text = "Volumen"
            cell.detailTextLabel?.text = String(describing: model.volume)
        case 3:
            cell.textLabel?.text = "Cambio"
            cell.detailTextLabel?.text = String(describing: model.change)
        default:
            break
        }
        return cell
    }

    //MARK: - IPC Model delegate
    func ipcDataFetched(_ points: [IPCPoint]) {
        modelData = points
        tableView.reloadData()
    }
}
