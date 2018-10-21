//
//  ConfigEditViewController.swift
//  Final
//
//  Created by Victor on 7/28/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import UIKit

protocol ConfigEditDelegate {
    func complete(indexPath: IndexPath, positions: [GridPosition])
}

class ConfigEditViewController : UIViewController {
    var configuration: Configuration?
    var size = 20
    var indexPath: IndexPath?
    var delegate: ConfigEditDelegate?
    
    @IBOutlet weak var gridView: GridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // default Configuration editor grid
        gridView.rows = 20
        gridView.cols = 20
        
        if let config = self.configuration {
            // sets the navigation view controller title to configuration name
            self.navigationItem.title = config.title
            
            // initialize the grid
            for pos in config.contents {
                gridView.grid[pos.row, pos.col] = .alive
            }
        }
    }
    @IBAction func onSave(_ sender: Any) {
        let livingPositions = gridView.grid.living
        
        // returns the current live cells
        if let indexPath = self.indexPath {
            delegate?.complete(indexPath: indexPath, positions: livingPositions)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
