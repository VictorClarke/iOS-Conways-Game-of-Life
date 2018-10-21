//
//  ConfigParser.swift
//  Final
//
//  Created by Victor on 7/26/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import UIKit


class ConfigParser {
    
    // parses the json data from remote url and returns Configuration array
    
    static func parse(urlString: String, completion:@escaping(([Configuration]?)->())) {        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                completion(nil)
            } else {
                var configArray : [Configuration] = []
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
                    
                    var positionArray : [GridPosition] = []
                    
                    for configData in parsedData {
                        if let title = configData["title"] as? String,
                            let contentsData = configData["contents"] as? [[Int]] {
                            print(title)
                            
                            for positionData in contentsData {
                                if positionData.count == 2 {
                                    let position = GridPosition(positionData[0], positionData[1])
                                    positionArray.append(position)
                                }
                            }
                            
                            let config = Configuration(title: title, contents: positionArray)
                            configArray.append(config)
                            
                        }
                    }
                    completion(configArray)
                    
                } catch let error as NSError {
                    //Information about an error condition including a domain, a domain-specific error code, and application-specific information.
                    print(error)
                    completion(nil)
                }
            }
            
            
            }.resume()
            //Calling this function decrements the suspension count of a suspended dispatch queue or dispatch event source object. While the count is greater than zero, the object remains suspended. When the suspension count returns to zero, any blocks submitted to the dispatch queue or any events observed by the dispatch source while suspended are delivered.
    }
}
