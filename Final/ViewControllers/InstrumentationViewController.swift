//
//  InstrumentationViewController.swift
//  Final
//
//  Created by Victor on 7/28/17.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import UIKit

class InstrumentationViewController : UIViewController {
    @IBOutlet weak var tblConfig: UITableView!
    @IBOutlet weak var tfSize: UITextField!
    @IBOutlet weak var stepperSize: UIStepper!
    @IBOutlet weak var slInterval: UISlider!
    @IBOutlet weak var swRefresh: UISwitch!
    
    //Configuration array to be displayed
    var configs:[Configuration] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializes Configuration table delegate and datasource
        tblConfig.dataSource = self
        tblConfig.delegate = self
        
        //add delegate to textfield size
        tfSize.delegate = self
        
        // catches notification sent from another view controller
        let configNotificationName = Notification.Name("newConfig")
        NotificationCenter.default.addObserver(self, selector: #selector(onNewConfig(notification:)), name: configNotificationName, object: nil)
        
        // loads Configuratioin from remote url
        loadConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let timer = StandardProtocol.sharedInstance.refreshTimer, timer.isValid {
            swRefresh.setOn(true, animated: false)
        } else {
            swRefresh.setOn(false, animated: false)
        }
    }
    
    func onNewConfig(notification: Notification) {
        if let config = notification.userInfo?["config"] as? Configuration {
            self.configs.append(config)
            
            self.tblConfig.insertRows(at: [IndexPath(row: self.configs.count - 1, section: 0)], with: .automatic)
        }
    }
    @IBAction func onAddConfiguration(_ sender: Any) {
        
        //input configuration title
        
        let alert = UIAlertController(title: "New Configuration", message: "Enter a configuration title", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0] {
                
                // Once name is inputed, create new config and show on the table
                self.makeNewConfig(title: textField.text!)
                print("Text field: \(textField.text!)")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeNewConfig(title: String) {
        let newConfig = Configuration(title: title, contents: [])
        
        //insert created new config to the last element of the Configuration table
        self.configs.append(newConfig)
        self.tblConfig.insertRows(at: [IndexPath(row: self.configs.count - 1, section: 0)], with: .automatic)
    }
    
    @IBAction func onSizeChange(_ sender: Any) {
        tfSize.text = String(Int(stepperSize.value))
        
        setGridSize(size: Int(stepperSize.value))
    }
    @IBAction func onIntervalChange(_ sender: Any) {
        setRefreshTimer()
    }
    
    func setRefreshTimer() {
        let interval = slInterval.value
        
        if let timer = StandardProtocol.sharedInstance.refreshTimer {
            timer.invalidate()
        }
        
        StandardProtocol.sharedInstance.refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: { (timer) in
            
            let newGrid = StandardProtocol.sharedInstance.step() as! Grid
            
            if newGrid.countFor(state: .born) == 0 && newGrid.countFor(state: .died) == 0 {
                timer.invalidate()
                StandardProtocol.sharedInstance.refreshTimer = nil
                
                self.swRefresh.isOn = false
            }
            
        })
    }
    
    func stopRefreshTimer() {
        if let timer = StandardProtocol.sharedInstance.refreshTimer {
            timer.invalidate()
            StandardProtocol.sharedInstance.refreshTimer = nil
        }
    }
    
    func setGridSize(size: Int) {
        StandardProtocol.sharedInstance.rows = size
        StandardProtocol.sharedInstance.cols = size
    }
    
    @IBAction func onRefreshChange(_ sender: Any) {
        let isOn = self.swRefresh.isOn
        
        if isOn {
            setRefreshTimer()
        } else {
            stopRefreshTimer()
        }
    }
    
    func loadConfig() {
        // Loads the inital configuration array from remote url
        let urlString = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"
        ConfigParser.parse(urlString: urlString) { (configs) in
            if let configArray = configs {
                self.configs = configArray
                
                DispatchQueue.main.async {
                    self.tblConfig.reloadData()
                }
            } else {
                //error loading configuration
            }
        }
    }
}


extension InstrumentationViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configcell", for: indexPath)
        
        let config = configs[indexPath.row]
        cell.textLabel?.text = config.title
        
        return cell
    }
    
}

extension InstrumentationViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let config = configs[indexPath.row]
        let size = Int(tfSize.text!)!
        
        let editorVC = self.storyboard!.instantiateViewController(withIdentifier: "configeditvc") as! ConfigEditViewController
        editorVC.configuration = config
        editorVC.size = size
        editorVC.indexPath = indexPath
        editorVC.delegate = self
        
        self.navigationController?.pushViewController(editorVC, animated: true)
    }
}

extension InstrumentationViewController : ConfigEditDelegate {
    func complete(indexPath: IndexPath, positions: [GridPosition]) {
        self.configs[indexPath.row].contents = positions
//        self.tblConfig.reloadRows(at: [indexPath], with: .automatic)
    }
}


extension InstrumentationViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.tfSize {
            var size: Int = Int(tfSize.text!)!
            
            if size <= 1 {
                size = 1
            } else if size >= 100 {
                size = 100
            }
            
            stepperSize.value = Double(size)
            
            setGridSize(size: size)
        }
        
    }
}
