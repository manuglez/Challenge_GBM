//
//  ViewController.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import UIKit
import Charts

class IPCGraphViewController: UIViewController, IPCViewModelDelegate, ChartViewDelegate {
    /// Segue name to IPCTableViewController
    let segueIdToList = "toList"
    
    /// View Model data
    var points:[IPCViewModel] = []
    
    /// The UIActivityIndicator shown while the data is fetched from services
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    /// The view where the chart is drawn
    @IBOutlet weak var ipcChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let controller = IPCController()
        controller.viewModelDelegate = self
        controller.fetchAllDataPoints()
        indicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /// Action from the Bar Button item to display the Detail View
    ///
    /// - Parameters:
    ///     - sender: The Bar Button Item.
    @IBAction func listButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: segueIdToList, sender: self)
    }
    
    // MARK: - IPC ViewModel Delegate
    /// Dalegate notifying the event that data has fetched from services or database
    ///
    /// - Parameters:
    ///     - points: The array of objects od the model.
    func ipcDataFetched(_ points: [IPCViewModel]) {
        var entries: [ChartDataEntry] = []
        var c = 0
        var xAxisValues: [String] = []
        for item in points {
            entries.append(ChartDataEntry(x:Double(c), y: Double(item.price)))
           xAxisValues.append(item.date.dateString(withFormat: "HH:mm:ss"))
            c += 1
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Precio")
        //dataSet.colors = ChartColorTemplates.colorful()
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 3.0
        dataSet.setColor(.systemBlue)
        ipcChart.data = LineChartData(dataSet: dataSet)
        ipcChart.xAxis.valueFormatter = DateAxisValueFormatter(xAxisValues)
        ipcChart.xAxis.granularity = 1.0
        indicator.stopAnimating()
    }
    
    // MARK: - Chart View Delegate
}

/// This class from the Charts library is used to indicate hiw to display the data label on the x axis.
class DateAxisValueFormatter : NSObject, IAxisValueFormatter
{
    var dates: [String] = []
 
    init(_ dates: [String])
  {
    super.init()
    self.dates = dates
  }

  func stringForValue(_ value: Double, axis: AxisBase?) -> String
  {
    return dates[Int(value)]
  }
}
