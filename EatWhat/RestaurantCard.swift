//
//  RestaurantCard.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-04-06.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Cosmos
import SwiftyJSON
import WebKit
import Alamofire

class Alert {
    
    func msg(title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.show(alertView, sender: self)
        
    }
    
}

class RestaurantCard: UIView, UIWebViewDelegate {
    
    var swipeGesture = UISwipeGestureRecognizer()
    var didAnimateView = false
    var didShowReviewView = false
    var originalY: CGFloat = 0
    let defaults = UserDefaults.standard
    
    let phoneNumberKit = PhoneNumberKit()
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var doneButton: UIButton!
    @IBAction func doneAction(_ sender: Any) {
        showReviewsView()
    }
    @IBOutlet var reviewVisualView: UIVisualEffectView!
    @IBOutlet var reviewCard: ReviewCard!
    @IBOutlet var reviewCard2: ReviewCard!
    @IBOutlet var reviewCard3: ReviewCard!
    
    @IBOutlet var featuredImageView: UIImageView!
    
    @IBOutlet var headerView: UIVisualEffectView!
    @IBOutlet var restaurantNameLabel: UILabel!
    @IBOutlet var restaurantCategory: UILabel!
    @IBOutlet var restaurantStars: CosmosView!
    
    @IBOutlet var footerView: UIVisualEffectView!
    @IBOutlet var restaurantPriceRange: UILabel!
    @IBOutlet var restaurantDistance: UILabel!
    @IBOutlet var restaurantMap: UIButton!
    @IBOutlet var callRestaurant: UIButton!
    @IBOutlet var restaurantWebsite: UIButton!
    @IBOutlet var restaurantLocation: UILabel!
    @IBOutlet var restaurantPhone: UILabel!
    @IBOutlet var restaurantTransactions: UILabel!
    
    @IBOutlet var vibrancyRectangle: UIView!
    @IBOutlet var vibrancyAddress: UILabel!
    @IBOutlet var vibrancyContact: UILabel!
    @IBOutlet var vibrancyTransactions: UILabel!
    
    var tapGesture = UITapGestureRecognizer()
    var restaurantReviews = [RestaurantReview]()
    
    var restaurant: Restaurant! {
        
        didSet {
            
            self.reviewCard.layer.cornerRadius = 10.0
            self.reviewCard.layer.shadowColor = UIColor.black.cgColor
            self.reviewCard.layer.shadowPath = UIBezierPath(roundedRect: self.reviewCard.bounds, cornerRadius: 10.0).cgPath
            self.reviewCard.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.reviewCard.layer.shadowRadius = 10.0
            self.reviewCard.layer.shadowOpacity = 0.3
            
            self.reviewCard2.layer.cornerRadius = 10.0
            self.reviewCard2.layer.shadowColor = UIColor.black.cgColor
            self.reviewCard2.layer.shadowPath = UIBezierPath(roundedRect: self.reviewCard2.bounds, cornerRadius: 10.0).cgPath
            self.reviewCard2.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.reviewCard2.layer.shadowRadius = 10.0
            self.reviewCard2.layer.shadowOpacity = 0.3
            
            self.reviewCard3.layer.cornerRadius = 10.0
            self.reviewCard3.layer.shadowColor = UIColor.black.cgColor
            self.reviewCard3.layer.shadowPath = UIBezierPath(roundedRect: self.reviewCard3.bounds, cornerRadius: 10.0).cgPath
            self.reviewCard3.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.reviewCard3.layer.shadowRadius = 10.0
            self.reviewCard3.layer.shadowOpacity = 0.3
            
            loadReviews(id: restaurant.id) { (success) in
                                
                self.reviewCard.restaurantReview = self.restaurantReviews[0]
                self.reviewCard2.restaurantReview = self.restaurantReviews[1]
                self.reviewCard3.restaurantReview = self.restaurantReviews[2]
                
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
                restaurantWebsite.setImage(UIImage(named: browserImageName), for: .normal)
                
            }
            
            if defaults.object(forKey: "whichCell") == nil {
                
                defaults.set("Maps", forKey: "whichCell")
                
            }
            
            loadImage(restaurant.imageURL)
            
            restaurantNameLabel.text = restaurant.name
            restaurantCategory.text = restaurant.category
            restaurantStars.rating = Double(restaurant.rating)
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showReviewsView))
            tapGesture.numberOfTapsRequired = 1
            
            // restaurantStars.addGestureRecognizer(tapGesture)
            
            if restaurant.priceRange == "" {
                restaurantPriceRange.text = "No Price Range Available"
            } else {
                restaurantPriceRange.text = restaurant.priceRange
            }
            
            let distanceMeters = Measurement(value: restaurant.distance, unit: UnitLength.meters)
            let distanceKilometers = distanceMeters.converted(to: UnitLength.kilometers)
            
            var kilometers = String()
            
            if distanceKilometers.value < 1 {
                
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 2
                let measurementFormatter = MeasurementFormatter()
                measurementFormatter.unitOptions = .providedUnit
                measurementFormatter.numberFormatter = numberFormatter
                kilometers = "0" + measurementFormatter.string(from: distanceKilometers)
                
            } else {
                
                let numberFormatter = NumberFormatter()
                numberFormatter.maximumFractionDigits = 1
                let measurementFormatter = MeasurementFormatter()
                measurementFormatter.unitOptions = .providedUnit
                measurementFormatter.numberFormatter = numberFormatter
                kilometers = measurementFormatter.string(from: distanceKilometers)
                
            }

            restaurantDistance.text = "\(kilometers) away from you"
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
            
            originalY = footerView.bounds.origin.y
            self.footerView.bounds.origin.y -= (self.footerView.frame.height) - (self.restaurantPriceRange.frame.height + self.restaurantMap.frame.height)
            swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.moveDown))
            swipeGesture.direction = UISwipeGestureRecognizerDirection.up
            
            if restaurant.transactions.isEmpty {
                
                restaurantTransactions.isHidden = true
                vibrancyTransactions.isHidden = true
                
            }
            
            restaurantMap.alpha = 0.0
            restaurantLocation.alpha = 0.0
            restaurantPhone.alpha = 0.0
            vibrancyAddress.alpha = 0.0
            vibrancyContact.alpha = 0.0
            vibrancyTransactions.alpha = 0.0
            vibrancyRectangle.alpha = 0.0
            
            restaurantWebsite.addTarget(self, action: #selector(self.openWebsite), for: .touchUpInside)
            callRestaurant.addTarget(self, action: #selector(self.callBusiness), for: .touchUpInside)
            restaurantMap.addTarget(self, action: #selector(self.openMaps), for: .touchUpInside)
            footerView.addGestureRecognizer(swipeGesture)
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed("RestaurantCard", owner: self, options: nil)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 15.0
        
        addSubview(contentView)
        
    }
    
    func reduceAddress(input: String) -> String {
        
        if input.range(of: "Boulevard") != nil {
            
            let replaced = (input as NSString).replacingOccurrences(of: "Boulevard", with: "Blvd")
            return replaced
            
        } else {
            
            return input
            
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
                        alert.msg(title: "Failed To Open Maps", message: "There's been a slight complication. Make sure you have Maps installed on you iPhone.")
                        
                    }
                    
                })
            }
            
        } else if let appName = defaults.object(forKey: "defaultMaps") as? String {
            
            if appName == "Apple Maps" {
                
                if let url = URL(string: "http://maps.apple.com/?address=\(addressString!)") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        
                        if !success {
                            
                            let alert = Alert()
                            alert.msg(title: "Failed To Open Maps", message: "There's been a slight complication. Make sure you have Maps installed on you iPhone.")
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
    
    func moveDown() {
        
        if didAnimateView {
            
            let mapsImageName = defaults.object(forKey: "defaultMaps") as! String
            restaurantMap.setImage(UIImage(named: mapsImageName), for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                
                self.restaurantMap.alpha = 0.0
                self.restaurantLocation.alpha = 0.0
                self.restaurantPhone.alpha = 0.0
                self.vibrancyAddress.alpha = 0.0
                self.vibrancyContact.alpha = 0.0
                self.vibrancyTransactions.alpha = 0.0
                self.vibrancyRectangle.alpha = 0.0
                self.footerView.bounds.origin.y -= (self.footerView.frame.height) - (self.restaurantPriceRange.frame.height + self.restaurantMap.frame.height)
                
            }
            
            didAnimateView = false
            
            swipeGesture.direction = UISwipeGestureRecognizerDirection.up
            
        } else {
            
            let mapsImageName = defaults.object(forKey: "defaultMaps") as! String
            restaurantMap.setImage(UIImage(named: mapsImageName), for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                
                self.restaurantMap.alpha = 1.0
                self.restaurantLocation.alpha = 1.0
                self.restaurantPhone.alpha = 1.0
                self.vibrancyAddress.alpha = 1.0
                self.vibrancyContact.alpha = 1.0
                self.vibrancyTransactions.alpha = 1.0
                self.vibrancyRectangle.alpha = 1.0
                self.footerView.bounds.origin.y = self.originalY
                
            }
            
            didAnimateView = true
            
            swipeGesture.direction = UISwipeGestureRecognizerDirection.down
            
        }
        
    }
    
    func showReviewsView() {
        
        print("ran this")
        
        if didShowReviewView {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.reviewVisualView.bounds.origin.y -= 500
                // self.reviewVisualView.alpha = 0.0
                
            })
            
            didShowReviewView = false
            
            self.restaurantStars.addGestureRecognizer(tapGesture)
            
            
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.reviewVisualView.bounds.origin.y += 500
                // self.reviewVisualView.alpha = 1.0
                
            })
            
            didShowReviewView = true
            
            // remove here
            self.reviewVisualView.isUserInteractionEnabled = true
            self.restaurantStars.removeGestureRecognizer(tapGesture)
            
        }
        
    }
    
    func loadImage(_ urlString: String) {
        
        if let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    
                    if error == nil {
                        
                        DispatchQueue.main.async {
                            
                            if let dataToUse = data {
                                self.featuredImageView.image = UIImage(data: dataToUse)!
                            }
                        }
                    }
                }
                
                task.resume()
                
            }
            
        }
        
    }
    
    func loadReviews(id: String, completetionHandler: @escaping (Bool) -> Void) {
        
        let headers: HTTPHeaders = ["Authorization": "Bearer Y43yqZUkj6vah5sgOHU-1PFN2qpapJsSwXZYScYTo0-nK9w5Y3lDvrdRJeG1IpQAADep0GrRL5ZDv6ybln03nIVzP7BL_IzAf_s7Wj5_QLPOO6oXns-nJe3-kIPiWHYx"]
        
        Alamofire.request("https://api.yelp.com/v3/businesses/\(id)/reviews", headers: headers).responseJSON { (Response) in
            
            if let value = Response.result.value {
                
                let json = JSON(value)
                
                for review in json["reviews"].arrayValue {
                    
                    let rating = review["rating"].intValue
                    let ratingText = review["text"].stringValue
                    let timePosted = review["time_created"].stringValue
                    
                    let userName = review["user"]["name"].stringValue
                    let imageURL = review["user"]["image_url"].stringValue
                    
                    let RFC3339DateFormatter = DateFormatter()
                    RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    RFC3339DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    let date = RFC3339DateFormatter.date(from: timePosted)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let dateToUse = dateFormatter.string(from: date!)
                    
                    let restaurantToUse = RestaurantReview(name: userName, reviewDate: dateToUse, review: ratingText, rating: rating, imageURL: imageURL)
                    self.restaurantReviews.append(restaurantToUse)
                    
                }
                completetionHandler(true)
            }
            
        }
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
            return false
        }
        return true
    }
    
}