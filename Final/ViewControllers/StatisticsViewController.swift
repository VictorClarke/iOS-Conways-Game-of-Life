//
//  StatisticsViewController.swift
//  Final
//
//  Created by Victor on 7/28/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import UIKit

class StatisticsViewController : UIViewController {
    @IBOutlet weak var tvHistory: UITextView!
    
    override func viewDidLoad() {
        
        // When the grid state has changed, logs the changed state
        let changeNotification = Notification.Name("gridChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(onGridChanged), name: changeNotification, object: nil)
        
        // When the grid size changed, reset the log
        let resetNotification = Notification.Name("gridSizeChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: resetNotification, object: nil)
        
        tvHistory.text = ""
    }
    
    func onGridChanged() {
        if let grid = StandardProtocol.sharedInstance.grid as? Grid {
            var history:String = tvHistory.text
            history += "\nNext state:\n"
            
            // enumerates all available status and logs for the count of the state of grid
            for state in CellState.allValues {
                
                history += state.description + ": " + String(grid.countFor(state: state)) + "\n"
            }
            tvHistory.text = history
        }
    }
    
    @IBAction func onReset(_ sender: Any) {
        let rows = StandardProtocol.sharedInstance.rows
        let cols = StandardProtocol.sharedInstance.cols
        StandardProtocol.sharedInstance.grid = Grid(rows, cols)
        reset()
    }
    
    func reset() {
        tvHistory.text = ""
    }
}
