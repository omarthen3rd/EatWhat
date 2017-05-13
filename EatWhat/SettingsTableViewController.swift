//
//  SettingsTableViewController.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-04-14.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import NotificationCenter

class UIPickerCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var appIcon: UIImageView!
    @IBOutlet var picker: UIPickerView!
    
    var arr = [String]()
    
    let defaults = UserDefaults.standard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picker.dataSource = self
        picker.delegate = self
        
        self.selectionStyle = .default
        
        var pickerString = ""
        var pickerIndex = 0
        
        switch defaults.object(forKey: "whichCell") as! String {
        case "Maps":
            arr = ["Apple Maps", "Google Maps", "Waze"]
            pickerString = defaults.object(forKey: "defaultMaps") as! String
            pickerIndex = arr.index(of: pickerString)!
            picker.selectRow(pickerIndex, inComponent: 0, animated: true)
        case "Browser":
            arr = ["Safari", "Google Chrome"]
            pickerString = defaults.object(forKey: "defaultBrowser") as! String
            pickerIndex = arr.index(of: pickerString)!
            picker.selectRow(pickerIndex, inComponent: 0, animated: true)
        default:
            arr = ["Apple Maps", "Google Maps", "Waze"]
            pickerString = defaults.object(forKey: "defaultMaps") as! String
            pickerIndex = arr.index(of: pickerString)!
            picker.selectRow(pickerIndex, inComponent: 0, animated: true)
        }
        
    }
    
}

extension UIPickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let name = arr[row]
        appIcon.image = UIImage(named: name)
        
        if arr.contains("Safari") {
            defaults.set(name, forKey: "defaultBrowser")
        } else {
            defaults.set(name, forKey: "defaultMaps")
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arr[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}

class SettingsTableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    var selectedIndex : NSInteger! = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBlur()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "DEFAULTS"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UIPickerCell
                        
            defaults.set("Browser", forKey: "whichCell")
            
            cell.label.text = "Default Maps App"
            cell.appIcon?.image = UIImage(named: defaults.object(forKey: "defaultMaps") as! String) ?? UIImage(named: "Apple Maps")
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UIPickerCell
            
            defaults.set("Maps", forKey: "whichCell")
            
            cell.label.text = "Default Browser App"
            cell.appIcon?.image = UIImage(named: defaults.object(forKey: "defaultBrowser") as! String) ?? UIImage(named: "Safari")
            
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == selectedIndex {
            
            selectedIndex = -1
            
        } else {
            
            selectedIndex = indexPath.row
            
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == selectedIndex {
            
            return 250
            
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
