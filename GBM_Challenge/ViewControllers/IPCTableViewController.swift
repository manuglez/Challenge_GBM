//
//  IPCTableViewController.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import UIKit

class IPCTableViewController: UITableViewController, IPCModelDelegate {
    let cellIdentifier = "cellIdetifier"
    
    // model that reprecents our data
    var modelData: [IPCPoint] = []
    
    // our controller that fetches data from services and database
    var ipcCpntroller = IPCController()
    
    // A DiipatchQueue that waits every 'delayTime' secondos to fetch de data from services.
    var delayThread: DispatchWorkItem?
    let delayTime = 5.0 // Tiempo de espera de 5 segundos
    
    // Our flag that indicates to sort our data by date in ascendig or descending order
    var descendingOrder = true
    
    // Names for the Bar button icon image to show the current order.
    let ascendingImageName = "arrow.up.to.line.alt"
    let descendingImageName = "arrow.down.to.line.alt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipcCpntroller.modelDelegate = self
        ipcCpntroller.fetchAllDataPoints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDelayTask()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ipcCpntroller.modelDelegate = nil
        ipcCpntroller.viewModelDelegate = nil
        invalidateDelayThread()
    }
    
    /// Bar button item action that toggles the value in 'descendingOrder' flag.
    ///
    /// - Parameters:
    ///     - sender: The Bar Button Item.
    @IBAction func toggleOrder(_ sender: Any){
        descendingOrder = !descendingOrder
        navigationItem.rightBarButtonItem?.image = UIImage(
            systemName: descendingOrder ? ascendingImageName : descendingImageName
        )
        sortData()
        tableView.reloadData()
    }
    
    // MARK: - Functions
    /// Sorts the model data by date in descending order whef descendingOrder is true
    /// sorts in ascending order otherwise,
    func sortData(){
        modelData.sort { ($0.date > $1.date) == descendingOrder }
    }
    
    /// Calls the web service to reload the data
    func reloadServiceData(){
        ipcCpntroller.fetchDataFromService()
        let indicator = UIActivityIndicatorView(style: .medium)
        self.navigationItem.titleView = indicator
        indicator.startAnimating()
    }
    
    // MARK: - Timer % Delay Functions
    func startDelayTask()
    {
        delayThread = DispatchWorkItem(block: {
            self.reloadServiceData()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: delayThread!)
    }
    
    /// Stops the current DispatchQueue that is waiting to execute.
    func invalidateDelayThread()
    {
        if let delayT = delayThread
        {
            if !delayT.isCancelled{
                delayT.cancel()
            }
        }
        delayThread = nil
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
    /// Dalegate notifying the event that data has fetched from services
    ///
    /// - Parameters:
    ///     - points: The array of objects od the model.
    func ipcDataFetched(_ points: [IPCPoint]) {
        modelData = points
        sortData()
        tableView.reloadData()
        self.navigationItem.titleView = nil
        startDelayTask()
    }
}
