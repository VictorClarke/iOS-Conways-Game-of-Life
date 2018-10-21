//
//  Configuration.swift
//  Final
//
//  Created by Victor on 7/28/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation

// Configuration Model
class Configuration {
    
    // title for the configuration
    var title: String
    
    // position array of cells currently live
    var contents: [GridPosition]
    
    // initializer
    required init(title: String, contents: [GridPosition]) {
        self.title = title
        self.contents = contents
    }
}
