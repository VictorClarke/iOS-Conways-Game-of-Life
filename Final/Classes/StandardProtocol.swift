//
//  Protocols.swift
//  Final
//
//  Created by Victor on 7/26/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import UIKit

protocol EngineDelegate {
    func engineDidUpdate(engine: EngineProtocol)
}


// EngineProtocol for the grid of Game of Life
protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol? { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    
    // rows of the grid
    var rows: Int { get set }
    
    // cols of the grid
    var cols: Int { get set }
    
    // initializer for the grid
    init(rows: Int, cols: Int)
    
    // step to next state of the grid
    func step()->GridProtocol?
}

class StandardProtocol : EngineProtocol {
    var delegate: EngineDelegate?
    
    // when the grid has changed, broadcasts the notification
    var grid: GridProtocol? {
        didSet {
            delegate?.engineDidUpdate(engine: self)
            
            let notificationIdentifier: String = "gridChanged"
            let notificationName = Notification.Name(notificationIdentifier)

            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
    
    // refresh rate of the timer
    var refreshRate: Double = 0.0
    
    // timer
    var refreshTimer: Timer?
    
    // when rows of the grid changed broadcasts notification
    var rows: Int {
        didSet {
            self.grid = Grid(self.rows, self.cols)
            
            let notificationIdentifier: String = "gridSizeChanged"
            let notificationName = Notification.Name(notificationIdentifier)
            
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
    
    // when cols of the grid changed broadcasts notification
    var cols: Int {
        didSet {
            self.grid = Grid(self.rows, self.cols)
            
            let notificationIdentifier: String = "gridSizeChanged"
            let notificationName = Notification.Name(notificationIdentifier)
            
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
    
    // move to next step as the rules of Game of Life
    func step()->GridProtocol? {
        self.grid = self.grid?.next()
        
        return self.grid
    }

    // intializer for the grid
    required init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
    }
    
    // lazy singleton of the StandardProtocol
    static var sharedInstance: StandardProtocol = {
        let instance = StandardProtocol(rows:10, cols:10)
        
        // setup code
        
        return instance
    }()
}
