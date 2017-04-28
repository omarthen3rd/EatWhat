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
    var defaultMaps = UserDefaults.standard
    
    @IBOutlet var imageInCell: UIImageView!
    @IBOutlet var picker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapsArr = ["Apple Maps", "Google Maps", "Waze"]
        picker.delegate = self
        picker.dataSource = self
        
        if defaultMaps.object(forKey: "defaultMaps") == nil {
            
            // is first time opening, default to Apple Maps here
            defaultMaps.set("Apple Maps", forKey: "defaultMaps")
            print("ran first time Settings")
            
            
        } else {
            
            // set image here
            let stringToUse = defaultMaps.object(forKey: "defaultMaps") as! String
            let indexToUse = mapsArr.index(of: stringToUse)
            picker.selectRow(indexToUse!, inComponent: 0, animated: true)
            imageInCell.image = UIImage(named: stringToUse)
            print("ran NOT first time Settings")
            
        }
        
    }
    
    
}

extension PickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        defaultMaps.set(mapsArr[row], forKey: "defaultMaps")
        imageInCell.image = UIImage(named: mapsArr[row])
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mapsArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mapsArr[row]
    }
    
}

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var imagesCell: UIImageView!
    
    let defaultMaps = UserDefaults.standard
    var selectedIndex : NSInteger! = -1
    
    let arr = ["Apple Maps", "Google Maps", "Waze"]
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == selectedIndex{
            
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
