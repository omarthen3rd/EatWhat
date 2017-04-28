//
//  SettingsTableViewController.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-04-14.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class PickerCell: UITableViewCell {
    
    var mapsArr: [String] = []
    var browserArr: [String] = []
    
    let whichCell = UserDefaults.standard
    
    var defaultMaps = UserDefaults.standard
    var defaultBrowser = UserDefaults.standard
    
    @IBOutlet var cellLabel: UILabel!
    @IBOutlet var imageInCell: UIImageView!
    @IBOutlet var picker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapsArr = ["Apple Maps", "Google Maps", "Waze"]
        browserArr = ["Safari", "Google Chrome"]
        picker.delegate = self
        picker.dataSource = self
        
        if whichCell.object(forKey: "whichCell") == nil {
            
            if defaultMaps.object(forKey: "defaultMaps") == nil {
                
                // is first time opening, default to Apple Maps here
                defaultMaps.set("Apple Maps", forKey: "defaultMaps")
                
                
            } else {
                
                // set image here
                let stringToUse = defaultMaps.object(forKey: "defaultMaps") as! String
                let indexToUse = mapsArr.index(of: stringToUse)
                picker.selectRow(indexToUse!, inComponent: 0, animated: true)
                imageInCell.image = UIImage(named: stringToUse)
                
            }
            
        } else if whichCell.object(forKey: "whichCell") as! String == "Maps" {
            
            // use maps
            
            if defaultMaps.object(forKey: "defaultMaps") == nil {
                
                // is first time opening, default to Apple Maps here
                defaultMaps.set("Apple Maps", forKey: "defaultMaps")
                
                
            } else {
                
                // set image here
                let stringToUse = defaultMaps.object(forKey: "defaultMaps") as! String
                let indexToUse = mapsArr.index(of: stringToUse)
                picker.selectRow(indexToUse!, inComponent: 0, animated: true)
                imageInCell.image = UIImage(named: stringToUse)
                
            }

            
        } else {
            
            // use browser
            
            if defaultBrowser.object(forKey: "defaultBrowser") == nil {
                
                defaultBrowser.set("Safari", forKey: "defaultBrowser")
                
            } else {
                
                let stringToUse = defaultBrowser.object(forKey: "defaultBrowser") as! String
                let indexToUse = browserArr.index(of: stringToUse)
                picker.selectRow(indexToUse!, inComponent: 0, animated: true)
                imageInCell.image = UIImage(named: stringToUse)
                
            }
            
        }
        
    }
    
    
}

extension PickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if whichCell.object(forKey: "whichCell") as! String == "Maps" {
            
            defaultMaps.set(mapsArr[row], forKey: "defaultMaps")
            imageInCell.image = UIImage(named: mapsArr[row])
            
        } else {
            
            defaultBrowser.set(mapsArr[row], forKey: "defaultBrowser")
            imageInCell.image = UIImage(named: browserArr[row])
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if whichCell.object(forKey: "whichCell") == nil {
            
            return mapsArr.count
            
        } else if whichCell.object(forKey: "whichCell") as! String == "Maps" {
            
            return mapsArr.count
            
        } else {
            
            return browserArr.count
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if whichCell.object(forKey: "whichCell") == nil {
            
            return mapsArr[row]
            
        } else if whichCell.object(forKey: "whichCell") as! String == "Maps" {
            
            return mapsArr[row]
            
        } else {
                        
            return browserArr[row]
            
        }
        
    }
    
}

class SettingsTableViewController: UITableViewController {
    
    let whichCell = UserDefaults.standard
    
    let defaultMaps = UserDefaults.standard
    var selectedIndex : NSInteger! = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBlur()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlur() {
        
        self.tableView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        
        self.tableView.backgroundView = blurEffectView
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            // cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PickerCell
            
            cell.cellLabel.text = "Default Maps App"
            cell.whichCell.set("Maps", forKey: "whichCell")
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PickerCell
            
            cell.cellLabel.text = "Default Browser"
            cell.whichCell.set("Browser", forKey: "whichCell")
            
            return cell
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == selectedIndex {
            
            selectedIndex = -1
            
        } else {
            
            selectedIndex = indexPath.row
            
        }
        
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == selectedIndex {
            
            return 220
            
        } else {
            
            return 68
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
