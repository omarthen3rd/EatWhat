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

class FavouritesDetailTableViewController: UITableViewController {

    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var restaurantTitle: UILabel!
    @IBOutlet var restaurantCategory: UILabel!
    @IBOutlet var restaurantStars: CosmosView!
    @IBOutlet var restaurantPriceRange: UILabel!
    @IBOutlet var restaurantLocation: UILabel!
    @IBOutlet var restaurantPhone: UILabel!
    @IBOutlet var restaurantTransactions: UILabel!
    @IBOutlet var restaurantMap: UIButton!
    @IBOutlet var resturantPhone: UIButton!
    @IBOutlet var restaurantBrowser: UIButton!
    
    @IBOutlet var vibrancyLocation: UILabel!
    @IBOutlet var vibrancyPhone: UILabel!
    @IBOutlet var vibrancyTransactions: UILabel!
    
    let defaults = UserDefaults.standard
    var phoneNumberKit = PhoneNumberKit()
    
    var restaurant: Restaurantt! {
        
        didSet {
            
            setupView()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            let blurView = UIVisualEffectView(effect: blurEffect)
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
        let address = reduceAddress(input: restaurant.address)
        restaurantLocation.text = "\(address) \n\(restaurant.city), \(restaurant.state) \n\(restaurant.country)"
        
        do {
            
            let phoneNumber = try phoneNumberKit.parse(restaurant.phone)
            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .international)
            restaurantPhone.text = "Phone: \(formattedNumber)"
            
        } catch {
            
            restaurantPhone.text = "Phone: \(restaurant.phone)"
            
        }
        
        restaurantTransactions.text = ""
        
        for transaction in restaurant.transactions {
            
            restaurantTransactions.text = restaurantTransactions.text! + "\(transaction.uppercaseFirst) ✓ \n"
            
        }
        
        if restaurant.transactions.isEmpty {
            
            restaurantTransactions.isHidden = true
            vibrancyTransactions.isHidden = true
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reduceAddress(input: String) -> String {
        
        if input.range(of: "Boulevard") != nil {
            
            let replaced = (input as NSString).replacingOccurrences(of: "Boulevard", with: "Blvd")
            return replaced
            
        } else {
            
            return input
            
        }
        
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
