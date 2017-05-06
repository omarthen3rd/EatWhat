//
//  FavouritesTableViewController.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-04-30.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import Cosmos

class FavouritesCell: UITableViewCell {
    
    @IBOutlet var restaurantTitle: UILabel!
    @IBOutlet var restaurantCategory: UILabel!
    @IBOutlet var restaurantImage: UIImageView!
    @IBOutlet var restaurantStars: CosmosView!
    
}

class FavouritesTableViewController: UITableViewController {
    
    var favourites = [Restaurantt]()
    let defaults = UserDefaults.standard
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadFavourites()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFavourites() {
        
        if defaults.object(forKey: "favourites") == nil {
            
            
            
        } else {
            
            if let decodedArr = defaults.object(forKey: "favourites") as? Data {
                
                if let decodedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: decodedArr) as? [Restaurantt] {
                    
                    self.favourites = decodedRestaurants
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func loadSadView() {
        
        var noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
        noDataLabel.text = "No Favourites"
        noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
        noDataLabel.textAlignment = .center
        self.tableView.separatorColor = UIColor.clear
        self.tableView.backgroundView = noDataLabel
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if favourites.count > 0 {
            
            return 1
            
        } else {
            
            loadSadView()
            return 0
            
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favourites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavouritesCell
        
        cell.restaurantTitle?.text = favourites[indexPath.row].name
        cell.restaurantCategory?.text = favourites[indexPath.row].category
        cell.restaurantStars.rating = Double(favourites[indexPath.row].rating)
        
        if let url = URL(string: favourites[indexPath.row].imageURL) {
            
            cell.restaurantImage.sd_setImage(with: url)
            cell.restaurantImage.clipsToBounds = true
            cell.restaurantImage.layer.cornerRadius = 10
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let favourite = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            
            self.favourites.remove(at: indexPath.row)
            
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.favourites)
            self.defaults.set(encodedData, forKey: "favourites")
            self.defaults.synchronize()
            
            self.tableView.reloadData()
            
        }
        
        favourite.backgroundColor = UIColor.red
        
        
        return [favourite]
        
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

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
