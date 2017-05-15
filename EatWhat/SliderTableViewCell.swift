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
        
        defaults.set(discreteValue, forKey: "searchRadius")
        radiusLabel.text = "\(Int(discreteValue)) km"
        sender.value = discreteValue
        
    }

}
