//
//  FavouritesDetailTableViewController.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-05-06.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import Cosmos
import PhoneNumberKit
import Alamofire
import SwiftyJSON

class FavouritesDetailTableViewController: UITableViewController {

    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var restaurantTitle: UILabel!
    @IBOutlet var restaurantCategory: UILabel!
    @IBOutlet var restaurantStars: CosmosView!
    @IBOutlet var restaurantPriceRange: UILabel!
    @IBOutlet var restaurantLocation: UILabel!
    @IBOutlet var restaurantPhone: UILabel!
    @IBOutlet var restaurantTimings: UILabel!
    @IBOutlet var restaurantTransactions: UILabel!
    @IBOutlet var restaurantMap: UIButton!
    @IBOutlet var resturantPhone: UIButton!
    @IBOutlet var restaurantBrowser: UIButton!
    
    @IBOutlet var virbrantIconView: UIView!
    @IBOutlet var vibrancyLocation: UILabel!
    @IBOutlet var vibrancyPhone: UILabel!
    @IBOutlet var vibrancyTimings: UILabel!
    @IBOutlet var vibrancyTransactions: UILabel!
    
    let defaults = UserDefaults.standard
    var phoneNumberKit = PhoneNumberKit()
    var blurView = UIVisualEffectView()
    
    typealias TimeOfDay = (hour: Int, minute: Int)
    
    var restaurant: Restaurantt! {
        
        didSet {
            
            setupView()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }

    
    func setupView() {
        
        if let url = URL(string: restaurant.imageURL) {
            
            let backgroundImage = UIImageView()
            backgroundImage.sd_setImage(with: url)
            self.tableView.backgroundView = backgroundImage
            
            tableView.tableFooterView = UIView()
            
            backgroundImage.contentMode = .scaleAspectFill
            
            tableView.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backgroundImage.bounds
            backgroundImage.addSubview(blurView)
            
            cellImage.sd_setImage(with: url)
            
        }
        
        if defaults.object(forKey: "defaultMaps") == nil {
            
            defaults.set("Apple Maps", forKey: "defaultMaps")
            
        } else {
            
            let mapsImageName = defaults.object(forKey: "defaultMaps") as! String
            restaurantMap.setImage(UIImage(named: mapsImageName), for: .normal)
            
        }
        
        if defaults.object(forKey: "defaultBrowser") == nil {
            
            defaults.set("Safari", forKey: "defaultBrowser")
            
        } else {
            
            let browserImageName = defaults.object(forKey: "defaultBrowser") as! String
            restaurantBrowser.setImage(UIImage(named: browserImageName), for: .normal)
            
        }
        
        restaurantTitle.text = restaurant.name
        restaurantCategory.text = restaurant.category
        restaurantStars.rating = Double(restaurant.rating)
        restaurantPriceRange.text = restaurant.priceRange
        restaurantPriceRange.textColor = UIColor.green
        let address = reduceAddress(input: restaurant.address)
        restaurantLocation.text = "\(address) \n\(restaurant.city), \(restaurant.state) \n\(restaurant.country)"
        
        do {
            
            let phoneNumber = try phoneNumberKit.parse(restaurant.phone)
            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .international)
            restaurantPhone.text = "Phone: \(formattedNumber)"
            
        } catch {
            
            restaurantPhone.text = "Phone: \(restaurant.phone)"
            
        }
        
        showBusinessDetails(restaurant.id) { (arr) in
            
            if !(arr.isEmpty) {
                
                for operationDay in arr {
                    
                    if operationDay.day == self.getCurrentDay() {
                        
                        self.restaurantTimings.text = "Hours: " + "\(operationDay.startTime) to " + "\(operationDay.endTime)"
                        
                    }
                    
                }
                
            }
            
        }
        
        restaurantTransactions.text = ""
        
        for transaction in restaurant.transactions {
            
            restaurantTransactions.text = restaurantTransactions.text! + "\(transaction.uppercaseFirst) ✓ \n"
            
        }
        
        if restaurant.transactions.isEmpty {
            
            restaurantTransactions.isHidden = true
            vibrancyTransactions.isHidden = true
            
        }
        
        resturantPhone.addTarget(self, action: #selector(self.callBusiness), for: UIControlEvents.touchUpInside)
        restaurantMap.addTarget(self, action: #selector(self.openMaps), for: UIControlEvents.touchUpInside)
        restaurantBrowser.addTarget(self, action: #selector(self.openWebsite), for: UIControlEvents.touchUpInside)
        
    }
    
    func showLoadingView() {
        
        let loadingView = UIView(frame: self.view.bounds)
        loadingView.backgroundColor = UIColor.darkGray
        
        let activityIndicator = UIActivityIndicatorView(frame: loadingView.frame)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        loadingView.addSubview(activityIndicator)
        self.view.addSubview(loadingView)
        
    }

    func reduceAddress(input: String) -> String {
        
        if input.range(of: "Boulevard") != nil {
            
            let replaced = (input as NSString).replacingOccurrences(of: "Boulevard", with: "Blvd")
            return replaced
            
        } else {
            
            return input
            
        }
        
    }
    
    func compareDates(_ time: String) {
        
        let calendar = Calendar.autoupdatingCurrent
        
        var timeToUse = time
        timeToUse.insert(":", at: time.index(time.startIndex, offsetBy: 2))
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let dateToUse = timeFormatter.date(from: timeToUse)
        
        let components = calendar.dateComponents([.hour, .minute], from: dateToUse!)
        let hourToUse = components.hour
        let minuteToUse = components.minute
        
        let components2 = calendar.dateComponents([.hour, .minute], from: Date())
        let hourToUse2 = components2.hour
        let minuteToUse2 = components2.minute
        
        var timeOfDay = [TimeOfDay]()
        timeOfDay.append((hourToUse!, minuteToUse!))
        timeOfDay.append((hourToUse2!, minuteToUse2!))
        
        print(timeOfDay)
        
        
    }
    
    func getCurrentDay() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let timeZoneAbbr = TimeZone.current.abbreviation()
        
        let day = calendar.component(.weekday, from: date)
        
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: timeZoneAbbr!)
        
        var weekDay = String()
        
        switch day {
            
        case 2:
            weekDay = "Monday"
        case 3:
            weekDay = "Tuesday"
        case 4:
            weekDay = "Wednesday"
        case 5:
            weekDay = "Thursday"
        case 6:
            weekDay = "Friday"
        case 7:
            weekDay = "Saturday"
        case 1:
            weekDay = "Sunday"
        default:
            weekDay = "Unknown"
            
        }
        
        return weekDay
        
    }
    
    
    func showBusinessDetails(_ id: String, completionHandler: @escaping ([RestaurantHours]) -> ()) {
        
        let headers = ["Authorization": "Bearer Y43yqZUkj6vah5sgOHU-1PFN2qpapJsSwXZYScYTo0-nK9w5Y3lDvrdRJeG1IpQAADep0GrRL5ZDv6ybln03nIVzP7BL_IzAf_s7Wj5_QLPOO6oXns-nJe3-kIPiWHYx"]
        var restaurantHoursEmbedded = [RestaurantHours]()
        
        Alamofire.request("https://api.yelp.com/v3/businesses/\(id)", headers: headers).responseJSON { (Response) in
            
            if let value = Response.result.value {
                
                let json = JSON(value)
                
                for day in json["hours"].arrayValue {
                    
                    for thingy in day["open"].arrayValue {
                        
                        let isOvernight = thingy["is_overnight"].boolValue
                        
                        let openTime = self.timeConverter(thingy["start"].stringValue)
                        let endTime = self.timeConverter(thingy["end"].stringValue)
                        
                        var weekDay = String()
                        
                        switch thingy["day"].intValue {
                            
                        case 0:
                            weekDay = "Monday"
                        case 1:
                            weekDay = "Tuesday"
                        case 2:
                            weekDay = "Wednesday"
                        case 3:
                            weekDay = "Thursday"
                        case 4:
                            weekDay = "Friday"
                        case 5:
                            weekDay = "Saturday"
                        case 6:
                            weekDay = "Sunday"
                        default:
                            weekDay = "Unknown"
                            
                        }
                        
                        let dayToUse = RestaurantHours(day: weekDay, isOvernight: isOvernight, startTime: openTime, endTime: endTime)
                        restaurantHoursEmbedded.append(dayToUse)
                        
                    }
                    
                }
                
                completionHandler(restaurantHoursEmbedded)
            }
            
        }
        
    }
    
    func openWebsite() {
        
        if defaults.object(forKey: "defaultBrowser") == nil {
            
            if let url = URL(string: restaurant.website) {
                
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    
                    if !success {
                        
                        let alert = Alert()
                        alert.msg(title: "Failed To Open Safari", message: "There's been a slight complication. This shouldn't be happening.")
                        
                    }
                    
                })
                
            }
            
        } else if let browserName = defaults.object(forKey: "defaultBrowser") as? String {
            
            if browserName == "Safari" {
                
                if let url = URL(string: restaurant.website) {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            
                            let alert = Alert()
                            alert.msg(title: "Failed To Open Safari", message: "There's been a slight complication. This shouldn't be happening.")
                            
                        }
                        
                    })
                    
                }
                
            } else if browserName == "Google Chrome" {
                
                if let url = URL(string: "googlechromes://\(restaurant.website)") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            
                            let alert = Alert()
                            alert.msg(title: "Failed To Open Google Chrome", message: "There's been a slight complication. Google Chrome isn't installed on your iPhone.")
                            
                        }
                        
                    })
                    
                }
                
            }
            
        }
        
    }
    
    func callBusiness() {
        
        if let url = URL(string: "tel://\(restaurant.phone)") {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                
                if !success {
                    
                    let alert = Alert()
                    alert.msg(title: "Failed To Call", message: "There's been a slight complication. The call cannot be made, make sure you are using an iPhone or a compatible device.")
                }
                
            })
            
        }
        
    }
    
    func openMaps() {
        
        let string = "\(restaurant.address),\(restaurant.city),\(restaurant.country)"
        let addressString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if defaults.object(forKey: "defaultMaps") == nil {
            
            if let url = URL(string: "http://maps.apple.com/?address=\(addressString!)") {
                
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    
                    if !success {
                        
                        let alert = Alert()
                        alert.msg(title: "Failed To Open Maps", message: "There's been a slight complication. Make sure you have Maps installed on your iPhone.")
                        
                    }
                    
                })
            }
            
        } else if let appName = defaults.object(forKey: "defaultMaps") as? String {
            
            if appName == "Apple Maps" {
                
                if let url = URL(string: "http://maps.apple.com/?address=\(addressString!)") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            
                            let alert = Alert()
                            alert.msg(title: "Failed To Open Maps", message: "There's been a slight complication. Make sure you have Maps installed on your iPhone.")
                        }
                        
                    })
                }
                
            } else if appName == "Waze" {
                
                if let url = URL(string: "waze://?q=\(addressString!)") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            
                            let alert = Alert()
                            alert.msg(title: "Failed To Open Waze", message: "There's been a slight complication. Waze isn't installed on your iPhone.")
                            
                        }
                        
                    })
                    
                }
                
            } else if appName == "Google Maps" {
                
                if let url = URL(string: "comgooglemaps://?q=\(addressString!)") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            
                            let alert = Alert()
                            alert.msg(title: "Failed To Open Google Maps", message: "There's been a slight complication. Google Maps isn't installed on your iPhone.")
                        }
                        
                    })
                    
                    
                }
                
            }
            
        }
        
    }
    
    func timeConverter(_ time: String) -> String {
        
        var timeToUse = time
        timeToUse.insert(":", at: time.index(time.startIndex, offsetBy: 2))
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let dateToUse = timeFormatter.date(from: timeToUse)
        
        timeFormatter.dateFormat = "h:mm a"
        let date12 = timeFormatter.string(from: dateToUse!)
        
        return date12
        
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
