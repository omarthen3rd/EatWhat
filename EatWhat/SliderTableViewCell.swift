//
//  SliderTableViewCell.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-05-14.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell {
    
    var defaults = UserDefaults.standard
    
    @IBOutlet var radiusLabel: UILabel!
    @IBOutlet var slider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSearchRadius(_ sender: UISlider) {
        
        let discreteValue = roundf(sender.value)
        
        let searchKm = Measurement(value: Double(discreteValue), unit: UnitLength.kilometers)
        let searchMeters = searchKm.converted(to: UnitLength.meters)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.numberFormatter = numberFormatter
        
        let searchToUse = measurementFormatter.string(from: searchMeters)
        let oneReplaced = searchToUse.replacingOccurrences(of: " m", with: "")
        
        if let intVal = Int(oneReplaced) {
            
            defaults.set(intVal, forKey: "searchRadius")
            radiusLabel.text = "\(Int(discreteValue)) km"
            sender.value = discreteValue
            
        }
        
    }

}
