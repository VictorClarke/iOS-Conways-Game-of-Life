//
//  SimulationViewController.swift
//  Final
//
//  Created by Victor on 7/28/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import UIKit

class SimulationViewController : UIViewController {
    
    @IBOutlet weak var gridView: GridView!
    
    override func viewDidLoad() {
        StandardProtocol.sharedInstance.delegate = self
        
        // When the grid size changed, update the GridView
        let resetNotification = Notification.Name("gridSizeChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(updateGrid), name: resetNotification, object: nil)
        
        self.resetGrid()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StandardProtocol.sharedInstance.grid = gridView.grid
    }
    
    @IBAction func onStep(_ sender: Any) {
        simulateNextStep()
    }
    
    func simulateNextStep() {
        StandardProtocol.sharedInstance.grid = self.gridView.grid
        _ = StandardProtocol.sharedInstance.step()
    }
    
    func updateGrid() {
        resetGrid()
    }
    
    @IBAction func onSave(_ sender: Any) {
        //Input new configuration title
        let alert = UIAlertController(title: "New Configuration", message: "Enter a configuration title", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0] {
                self.saveNewConfig(title: textField.text!)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onReset(_ sender: Any) {
        resetGrid()
        
        StandardProtocol.sharedInstance.refreshTimer?.invalidate()
        StandardProtocol.sharedInstance.refreshTimer = nil
    }
    
    func resetGrid() {
        let rows = StandardProtocol.sharedInstance.rows
        let cols = StandardProtocol.sharedInstance.cols
        
        self.gridView.rows = rows
        self.gridView.cols = cols
    }
    
    func saveNewConfig(title: String) {
        let positions: [GridPosition] = self.gridView.grid.living
        let config = Configuration(title: title, contents: positions)
        
        let newConfigNotification = Notification.Name("newConfig")
        
        NotificationCenter.default.post(name: newConfigNotification, object: nil, userInfo: ["config":config])
    }
}

extension SimulationViewController : EngineDelegate {
    func engineDidUpdate(engine: EngineProtocol) {
        
        // when engine has changed, update the gridView
        if let grid = engine.grid as? Grid {
            gridView.grid = grid
            gridView.setNeedsDisplay()
        }
    }
}
