//
//  ViewController.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-04-03.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SwiftyJSON
import Alamofire
import PhoneNumberKit
import SystemConfiguration

extension String {
    
    init(htmlEncodedString: String) {
        do {
            let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)
            ]
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self.init(attributedString.string)!
        } catch {
            fatalError("Unhandled error: \(error)")
        }
    }
    
    var first: String {
        return String(characters.prefix(1))
    }
    
    var last: String {
        return String(characters.suffix(1))
    }
    
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
    
}

extension NSMutableAttributedString {
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        }
    }
    
    func setBoldForText(_ textToFind: String) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
            addAttributes(attrs, range: range)
        }
        
    }
    
}

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }

}

extension UIImageView {
    
    func addBlurEffect(_ style: UIBlurEffectStyle) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
}

struct RestaurantType {
    
    var id: Int
    var name: String
    
}

class RestaurantHours: NSObject, NSCoding {
    
    var day: String
    var isOvernight: Bool
    var startTime: String
    var endTime: String
    
    init(day: String, isOvernight: Bool, startTime: String, endTime: String) {
        
        self.day = day
        self.isOvernight = isOvernight
        self.startTime = startTime
        self.endTime = endTime
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let day = aDecoder.decodeObject(forKey: "day") as! String
        let isOvernight = aDecoder.decodeBool(forKey: "isOvernight")
        let startTime = aDecoder.decodeObject(forKey: "startTime") as! String
        let endTime = aDecoder.decodeObject(forKey: "endTime") as! String
        
        self.init(day: day, isOvernight: isOvernight, startTime: startTime, endTime: endTime)
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(day, forKey: "day")
        aCoder.encode(isOvernight, forKey: "isOvernight")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        
    }
    
}

class Restaurantt: NSObject, NSCoding {
    
    var name: String
    var website: String
    var imageURL: String
    var rating: Int
    var priceRange: String
    var phone: String
    var id: String
    var isClosed: Bool
    var category: String
    var reviewCount: Int
    var distance: Double
    
    var city: String
    var country: String
    var state: String
    var address: String
    var zipCode: String
    
    var transactions: [String]
    
    init(name: String, website: String, imageURL: String, rating: Int, priceRange: String, phone: String, id: String, isClosed: Bool, category: String, reviewCount: Int, distance: Double, city: String, country: String, state: String, address: String, zipCode: String, transactions: [String]) {
        
        self.name = name
        self.website = website
        self.imageURL = imageURL
        self.rating = rating
        self.priceRange = priceRange
        self.phone = phone
        self.id = id
        self.isClosed = isClosed
        self.category = category
        self.reviewCount = reviewCount
        self.distance = distance
        self.city = city
        self.country = country
        self.state = state
        self.address = address
        self.zipCode = zipCode
        self.transactions = transactions
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let website = aDecoder.decodeObject(forKey: "website") as! String
        let imageURL = aDecoder.decodeObject(forKey: "imageURL") as! String
        let rating  = aDecoder.decodeInteger(forKey: "rating")
        let priceRange = aDecoder.decodeObject(forKey: "priceRange") as! String
        let phone = aDecoder.decodeObject(forKey: "phone") as! String
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let isClosed = aDecoder.decodeBool(forKey: "isClosed")
        let category = aDecoder.decodeObject(forKey: "category") as! String
        let reviewCount = aDecoder.decodeInteger(forKey: "reviewCount")
        let distance = aDecoder.decodeDouble(forKey: "distance")
        let city = aDecoder.decodeObject(forKey: "city") as! String
        let country = aDecoder.decodeObject(forKey: "country") as! String
        let state = aDecoder.decodeObject(forKey: "state") as! String
        let address = aDecoder.decodeObject(forKey: "address") as! String
        let zipCode = aDecoder.decodeObject(forKey: "zipCode") as! String
        let transactions = aDecoder.decodeObject(forKey: "transactions") as! [String]
        
        self.init(name: name, website: website, imageURL: imageURL, rating: rating, priceRange: priceRange, phone: phone, id: id, isClosed: isClosed, category: category, reviewCount: reviewCount, distance: distance, city: city, country: country, state: state, address: address, zipCode: zipCode, transactions: transactions)
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(website, forKey: "website")
        aCoder.encode(imageURL, forKey: "imageURL")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(priceRange, forKey: "priceRange")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(isClosed, forKey: "isClosed")
        aCoder.encode(category, forKey: "category")
        aCoder.encode(reviewCount, forKey: "reviewCount")
        aCoder.encode(distance, forKey: "distance")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(zipCode, forKey: "zipCode")
        aCoder.encode(transactions, forKey: "transactions")
        
    }
    
}

struct RestaurantReview {
    
    var name: String
    var reviewDate: String
    var review: String
    var rating: Int
    var imageURL: String
    
}

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var wallpaperVisualView: UIVisualEffectView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var containerVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var vibrancyView: UIView!
    
    @IBOutlet var alertView: UIVisualEffectView!
    @IBOutlet var alertViewImage: UIImageView!
    @IBOutlet var alertViewLabel: UILabel!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var noresultsLabel: UILabel!
    @IBOutlet var spinningView: UIActivityIndicatorView!
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
        
    var snapBehavior: UISnapBehavior!
    var animator: UIDynamicAnimator!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var scrollView: UIScrollView!
    
    var leftTapGesture = UITapGestureRecognizer()
    var rightTapGesture = UITapGestureRecognizer()
    
    var locationManager = CLLocationManager()
    var locationToUse = String()
    
    var viewIsOpen = false
    var didGetLocation = false
    var didUpdateLocationCount = 0
    var newCount = 0
    
    let defaults = UserDefaults.standard
    var accessToken = String()
    var categories = [String]()
    var selectedCategory = String()
    
    var lat = Double()
    var long = Double()
    var searchRadius: Int = 5000 // 5 KM
    var sortLabel = UILabel()
    var sortByView = UIView()
    var orderLabel = UILabel()
    var orderByView = UIView()
    var sadView = UIView()
    var restaurantTypesButton = UIButton()
    
    var card = RestaurantCard()
    
    var selectedId = -100
    var sortedBy = "rating"
    var orderedBy = "desc"
    
    var restaurantTypes = [RestaurantType]()
    var restaurantss = [Restaurantt]()
    var favouriteRestaurants = [Restaurantt]()
    var restaurantReviews = [RestaurantReview]()
    
    var restaurantIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallpaperVisualView.effect = nil
        self.spinningView.startAnimating()
        
        UIView.animate(withDuration: 1.5, animations: {
            
            self.wallpaperVisualView.effect = UIBlurEffect(style: .light)
            
        }, completion: nil)
        
        let internetIsAvailable = isInternetAvailable()
        
        if internetIsAvailable {
            
            locationManager.delegate = self
            locationManager.distanceFilter = 100
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
            
        } else {
            
            self.noresultsLabel.isHidden = false
            self.noresultsLabel.text = "No Internet Connection"
            
        }
        
    }
    
    func loadCard(_ button: UIButton) {
                
        self.middleButton.isUserInteractionEnabled = false
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addToFavourites))
        doubleTapGesture.numberOfTapsRequired = 2
        self.card = RestaurantCard(frame: CGRect(x: 0, y: 0, width: 343, height: 449))
        self.card.restaurant = self.restaurantss[self.restaurantIndex]
        self.card.translatesAutoresizingMaskIntoConstraints = false
        self.card.addGestureRecognizer(doubleTapGesture)
        
        if button.tag == 1 {
            
            // like / right button
            
            self.card.alpha = 0.0
            self.card.frame.origin.y = 109
            self.card.frame.origin.x += 400
            UIView.animate(withDuration: 0.3, animations: {
                
                self.card.frame.origin.x -= 400
                self.card.alpha = 1.0
                self.view.addSubview(self.card)
                
                let margins = self.view.layoutMarginsGuide
                
                self.card.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
                self.card.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
                self.card.topAnchor.constraint(equalTo: margins.topAnchor, constant: 109).isActive = true
                self.card.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -109).isActive = true
                self.card.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 16)
                self.card.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: 0)
                
                self.view.layoutIfNeeded()
                self.card.layoutIfNeeded()
                
            
            }, completion: { (success) in
                
                if self.viewIsOpen {
                    
                    self.handleTap(self.middleButton)
                    self.dislikeButton.isUserInteractionEnabled = false
                    
                }
                
                self.spinningView.stopAnimating()
                button.isUserInteractionEnabled = true
                self.middleButton.isUserInteractionEnabled = true
                self.dislikeButton.isUserInteractionEnabled = true
                
            })
            
        } else {
            
            // dislike / left
            
            self.card.alpha = 0.0
            self.card.frame.origin.y = 109
            self.card.frame.origin.x -= 900
            UIView.animate(withDuration: 0.3, animations: {
                
                self.card.frame.origin.x += 900
                self.card.alpha = 1.0
                self.view.addSubview(self.card)
                
                let margins = self.view.layoutMarginsGuide
                
                self.card.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
                self.card.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
                self.card.topAnchor.constraint(equalTo: margins.topAnchor, constant: 109).isActive = true
                self.card.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -109).isActive = true
                self.card.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 16)
                self.card.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: 0)
                
                self.view.layoutIfNeeded()
                self.card.layoutIfNeeded()
                
            }, completion: { (success) in
                
                button.isUserInteractionEnabled = true
                self.middleButton.isUserInteractionEnabled = true
                self.likeButton.isUserInteractionEnabled = true
                
            })
            
        }
        
        if self.restaurantIndex == 0 {
            // self.spinningView.stopAnimating()
            self.noresultsLabel.isHidden = true
            self.likeButton.isEnabled = true
            self.dislikeButton.isEnabled = false
        } else {
            // self.spinningView.stopAnimating()
            self.noresultsLabel.isHidden = true
            self.likeButton.isEnabled = true
            self.dislikeButton.isEnabled = true
        }
        
    }
    
    func loadInterface() {
        
        self.spinningView.hidesWhenStopped = true
        
        dislikeButton.addTarget(self, action: #selector(self.leftTap), for: .touchUpInside)
        dislikeButton.tag = 0
        likeButton.addTarget(self, action: #selector(self.rightTap), for: .touchUpInside)
        likeButton.tag = 1
        middleButton.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.containerVisualEffectView.frame.width, height: self.containerVisualEffectView.frame.height))
        scrollView.delegate = self
        
        self.vibrancyView.addSubview(scrollView)
        
        restaurantTypesButton = UIButton(frame: CGRect(x: 31.25, y: 55, width: 312.5, height: 45))
        restaurantTypesButton.setTitle("Eat What", for: .normal)
        restaurantTypesButton.setTitleColor(UIColor.black, for: .normal)
        restaurantTypesButton.titleLabel?.font = UIFont(name: "Finition PERSONAL USE ONLY", size: 40)
        restaurantTypesButton.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchDown)
        restaurantTypesButton.layer.cornerRadius = 10.0
        
        sortByView = UIView(frame: CGRect(x: 31.25, y: containerView.frame.origin.y + 360 + 18, width: 146, height: 140))
        sortByView.backgroundColor = UIColor.lightGray
        sortByView.layer.cornerRadius = 15.05
        sortByView.alpha = 0.0
        sortByView.clipsToBounds = true
        sortByView.isHidden = true
        
        sortLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 146, height: 35))
        sortLabel.text = "Sort: Rating"
        sortLabel.textAlignment = .center
        sortLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        
        let button = createSortButton("Rating", y: 35)
        let button2 = createSortButton("Cost", y: 70)
        let button3 = createSortButton("Distance", y: 105)
        button.addTarget(self, action: #selector(self.handleSortBy(_:)), for: .touchUpInside)
        button2.addTarget(self, action: #selector(self.handleSortBy(_:)), for: .touchUpInside)
        button3.addTarget(self, action: #selector(self.handleSortBy(_:)), for: .touchUpInside)
        
        sortByView.addSubview(sortLabel)
        sortByView.addSubview(button)
        sortByView.addSubview(button2)
        sortByView.addSubview(button3)
        
        orderByView = UIView(frame: CGRect(x: 197.25, y: containerView.frame.origin.y + 360 + 18, width: 146, height: 140))
        orderByView.backgroundColor = UIColor.lightGray
        orderByView.layer.cornerRadius = 15.0
        orderByView.alpha = 0.0
        orderByView.clipsToBounds = true
        orderByView.isHidden = true
        
        orderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 146, height: 46))
        orderLabel.text = "Order: Descending"
        orderLabel.textAlignment = .center
        orderLabel.numberOfLines = 0
        orderLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        
        let orderButton1 = createOrderButton("Ascending", y: 46)
        let orderButton2 = createOrderButton("Descending", y: 93)
        orderButton1.addTarget(self, action: #selector(self.handleOrderBy(_:)), for: .touchUpInside)
        orderButton2.addTarget(self, action: #selector(self.handleOrderBy(_:)), for: .touchUpInside)
        
        orderByView.addSubview(orderLabel)
        orderByView.addSubview(orderButton1)
        orderByView.addSubview(orderButton2)
        
        let allRestaurant = RestaurantType(id: -100, name: "All Types")
        restaurantTypes.insert(allRestaurant, at: 0)
        
        var buttonY: CGFloat = 0
        
        for category in categories {
            let button = createButton(category, y: buttonY)
            button.addTarget(self, action: #selector(self.handleSelectedRestaurant(_:_:)), for: .touchUpInside)
            button.setBackgroundColor(color: UIColor.darkGray, forState: .highlighted)
            buttonY += 40
            self.scrollView.addSubview(button)
        }
        
        scrollView.contentSize = CGSize(width: self.vibrancyView.bounds.width, height: buttonY)
        
        self.loadCard(likeButton)
        
        if let allTypesButton = scrollView.subviews[0] as? UIButton {
            
            self.handleSelectedRestaurant(allTypesButton, true)
            
        }
        
        // self.handleSelectedRestaurant(self.scrollView.subviews[0] as! UIButton, true)
        
    }
    
    func createButton(_ buttonTitle: String, y: CGFloat) -> UIButton {
        
        let button = UIButton(frame: CGRect(x: 0, y: y, width: self.vibrancyView.bounds.width, height: 40))
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        return button
        
    }
    
    func createSortButton(_ buttonTitle: String, y: CGFloat) -> UIButton {
        
        let button = UIButton(frame: CGRect(x: 0, y: y, width: 146, height: 35))
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
        
    }
    
    func createOrderButton(_ buttonTitle: String, y: CGFloat) -> UIButton {
        
        let button = UIButton(frame: CGRect(x: 0, y: y, width: 146, height: 50))
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
        
    }
    
    func leftTap() {
        
        self.dislikeButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.card.center = CGPoint(x: 300, y: self.card.center.y)
            self.card.alpha = 0.0
            
        }, completion: { (success) in
            
            self.card.removeFromSuperview()
            self.restaurantIndex -= 1
            
            if self.restaurantss.endIndex == self.restaurantIndex {
                
                self.noresultsLabel.text = "No More Results"
                self.noresultsLabel.isHidden = false
                
                self.dislikeButton.isEnabled = true
                self.likeButton.isEnabled = false
                
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.loadCard(self.dislikeButton)
                    }
                }
            }
            
        })
        
    }
    
    func rightTap() {
        
        self.likeButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.card.center = CGPoint(x: -300, y: self.card.center.y)
            self.card.alpha = 0.0
            
        }, completion: { (success) in
            
            self.card.removeFromSuperview()
            self.restaurantIndex += 1
            
            if self.restaurantss.endIndex == self.restaurantIndex {
                
                self.noresultsLabel.text = "No More Results"
                self.noresultsLabel.isHidden = false
                
                self.dislikeButton.isEnabled = true
                self.likeButton.isEnabled = false
                
                
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.loadCard(self.likeButton)
                    }
                }
            }
            
        })
        
    }
    
    func addToFavourites() {
        
        self.favouriteRestaurants.append(self.restaurantss[self.restaurantIndex])
        
        if defaults.object(forKey: "favourites") == nil {
                        
            // no favs, encode arr and replace
            
            self.showAlertView("Added To Favourites")
            
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.favouriteRestaurants)
            defaults.set(encodedData, forKey: "favourites")
            defaults.synchronize()
            
        } else {
            
            // favs are there, decode array, append to it, encode it, then archive and send to UserDefaults
            
            if let decodedArr = defaults.object(forKey: "favourites") as? Data {
                
                if var decodedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: decodedArr) as? [Restaurantt] {
                    
                    if !(decodedRestaurants.contains(where: { $0.id == self.restaurantss[self.restaurantIndex].id })) {
                        
                        self.showAlertView("Added To Favourites")
                        decodedRestaurants.append(self.restaurantss[self.restaurantIndex])
                        
                    } else {
                        
                        self.showAlertView("Already In Favourites")
                        // let alert = Alert()
                        // alert.msg(title: "Already In Favourites", message: "The restaurant you favourited is already in your favourites.")
                        
                        
                    }
                    
                    let encode: Data = NSKeyedArchiver.archivedData(withRootObject: decodedRestaurants)
                    defaults.set(encode, forKey: "favourites")
                    defaults.synchronize()
                    
                }
                
            }
            
        }
        
    }
    
    func handleOrderBy(_ button: UIButton) {
        
        /*
        
        self.orderLabel.text = "Order: \(button.currentTitle!)"
        self.card.removeFromSuperview()
        self.restaurants.removeAll()
        self.restaurantIndex = 0
        handleTap(self.restaurantTypesButton)
        self.searchRadius = 5000
        
        switch button.currentTitle! {
        case "Ascending":
            self.orderedBy = "asc"
        case "Descending":
            self.orderedBy = "desc"
        default:
            self.orderedBy = "desc"
        }
        
        self.getRestuarants(0, self.searchRadius, self.selectedId, self.sortedBy, self.orderedBy) { (success) in
            
            if success {
                if self.restaurants.isEmpty {
                    if !(self.view.subviews.contains(self.sadView)) {
                        DispatchQueue.global(qos: .userInitiated).async {
                            DispatchQueue.main.async {
                                self.loadSadView()
                            }
                        }
                    }
                } else {
                    if self.view.subviews.contains(self.sadView) {
                        self.sadView.removeFromSuperview()
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.load Card()
                        }
                    }
                }
            }
            
        } */
        
    }
    
    func handleSortBy(_ button: UIButton) {
        
        /*
        self.sortLabel.text = "Sort: \(button.currentTitle!)"
        self.card.removeFromSuperview()
        self.restaurants.removeAll()
        self.restaurantIndex = 0
        handleTap(self.restaurantTypesButton)
        self.searchRadius = 5000
        
        switch button.currentTitle! {
        case "Rating":
            self.sortedBy = "rating"
        case "Cost":
            self.sortedBy = "cost"
        case "Distance":
            self.sortedBy = "real_distance"
        default:
            self.sortedBy = "rating"
        }
        
        self.getRestuarants(0, self.searchRadius, self.selectedId, self.sortedBy, self.orderedBy) { (success) in
            
            if success {
                if self.restaurants.isEmpty {
                    if !(self.view.subviews.contains(self.sadView)) {
                        DispatchQueue.global(qos: .userInitiated).async {
                            DispatchQueue.main.async {
                                self.loadSadView()
                            }
                        }
                    }
                } else {
                    if self.view.subviews.contains(self.sadView) {
                        self.sadView.removeFromSuperview()
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.load Card()
                        }
                    }
                }
            }
            
        } */
        
    }
    
    func handleSelectedRestaurant(_ button: UIButton, _ onlySelect: Bool = false) {
        
        self.spinningView.startAnimating()
        self.dislikeButton.isEnabled = false
        self.likeButton.isEnabled = false
        
        if onlySelect {
            
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            button.backgroundColor = UIColor.darkGray
            self.dislikeButton.isEnabled = false
            self.likeButton.isEnabled = true
            
        } else {
            
            for thing in self.scrollView.subviews {
                
                if let thingy = thing as? UIButton {
                    
                    if thingy == button {
                        
                        thingy.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
                        thingy.backgroundColor = UIColor.darkGray
                        
                    } else {
                        
                        thingy.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                        thingy.backgroundColor = UIColor.clear
                    }
                    
                }
                
            }
            
            self.selectedCategory = button.currentTitle!
            self.card.removeFromSuperview()
            self.restaurantss.removeAll()
            self.restaurantIndex = 0
            handleTap(middleButton)
            self.searchBusinesses(self.lat, self.long) { (success) in
                
                if success {
                    
                    self.noresultsLabel.text = "Loading"
                    self.noresultsLabel.isHidden = false
                    
                    if self.restaurantss.isEmpty {
                        
                        self.noresultsLabel.text = "No Results"
                        self.spinningView.stopAnimating()
                        self.dislikeButton.isEnabled = false
                        self.likeButton.isEnabled = false
                        
                    } else {
                        
                        self.noresultsLabel.text = ""
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            DispatchQueue.main.async {
                                self.noresultsLabel.isHidden = true
                                self.loadCard(self.likeButton)
                            }
                        }
                        
                    }
                    
                } else {
                    
                    self.noresultsLabel.text = "No Results"
                    self.noresultsLabel.isHidden = false
                    self.spinningView.stopAnimating()
                    self.dislikeButton.isEnabled = false
                    self.likeButton.isEnabled = false
                    
                }
                
            }
            
        }
        
    }
    
    func handleTap(_ button: UIButton) {
        
        if viewIsOpen {
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.containerView.isHidden = true
                self.likeButton.isEnabled = true
                if self.restaurantIndex == 0 || self.restaurantss.isEmpty {
                    self.dislikeButton.isEnabled = false
                    if self.restaurantss.isEmpty {
                        self.likeButton.isEnabled = false
                    }
                } else if self.restaurantss.endIndex == self.restaurantIndex {
                    self.dislikeButton.isEnabled = true
                    self.likeButton.isEnabled = false
                } else {
                    self.dislikeButton.isEnabled = true
                }
                self.card.isHidden = false
                
            })
            
            self.viewIsOpen = false
            
        } else {
                        
            UIView.animate(withDuration: 0.3, animations: {
                
                self.containerView.isHidden = false
                
            }, completion: { (success) in
                
                self.view.bringSubview(toFront: self.card)
                self.card.isHidden = true
                self.dislikeButton.isEnabled = false
                self.likeButton.isEnabled = false
            })
            
            self.viewIsOpen = true
            
        }
        
    }
    
    func showAlertView(_ textToUse: String) {
        
        self.alertViewLabel.text = textToUse
        self.alertViewLabel.alpha = 0.0
        self.alertViewImage.image = UIImage(named: "favourite")?.withRenderingMode(.alwaysTemplate)
        self.alertViewImage.alpha = 0.0
        self.alertView.isHidden = false

        self.view.bringSubview(toFront: self.alertView)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.alertView.effect = UIBlurEffect(style: .dark)
            self.alertViewLabel.alpha = 1.0
            self.alertViewImage.alpha = 1.0
            
        }) { (success) in
            
            self.dismissAlertView()
            
        }
        
    }
    
    func dismissAlertView() {
        
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseIn, animations: { 
            
            self.alertView.effect = nil
            self.alertViewLabel.alpha = 0.0
            self.alertViewImage.alpha = 0.0
            
        }) { (success) in
            
            self.alertView.isHidden = true
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // add some kind of error view telling user to allow location
        
        if error != nil {
            
            let alrt = UIAlertController(title: "Please Enable Location Services", message: "This application cannot work without enabling Location Services.", preferredStyle: .alert)
            let alrtAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alrt.addAction(alrtAction)
            self.present(alrt, animated: true, completion: nil)
            
        }
        
    }
    
    private var didPerformGeocode = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        
        guard let location = locations.first, (locations.first?.horizontalAccuracy)! >= CLLocationAccuracy(0) else { return }
        
        guard !didPerformGeocode else { return }
        
        didPerformGeocode = true
        locationManager.stopUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            let coord = location.coordinate
            self.lat = coord.latitude
            self.long = coord.longitude
            
            self.restaurantss.removeAll()
            self.restaurantIndex = 0
            self.getCategories()
            self.searchBusinesses(self.lat, self.long, completetionHandler: { (success) in
                
                if success {
                    
                    self.loadInterface()
                }
            })
        }
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            self.locationToUse = locality!
        }
    }

    func getAccessToken() {
        
        let url = "https://api.yelp.com/oauth2/token?grant_type=client_credentials&client_id=6KSy_u1GxOmUyYEBgHBlkw&client_secret=dqmoQtAoUIt0XJf2lgBGu14xhtEHGkqAaN3MfG50v38eJ53shrFB3s8COC1snddB"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        Alamofire.request(request).responseJSON { (response) in
            
            if let value = response.result.value {
                
                let json = JSON(value)
                self.accessToken = json["access_token"].stringValue
                
            }
            
        }
        
    }
    
    func getCategories() {
        
        let url = "https://www.yelp.com/developers/documentation/v3/all_category_list/categories.json"
        
        Alamofire.request(url).responseJSON { (response) in
            
            if let value = response.result.value {
                
                let json = JSON(value)
                
                for item in json.arrayValue {
                    
                    let thing = item["parents"].arrayValue
                    for things in thing {
                        
                        let thingy = things.stringValue
                        if thingy == "restaurants" {
                            self.categories.append(item["title"].stringValue)
                        }
                    }
                    
                }
                self.categories.insert("All Types", at: 0)
                self.selectedCategory = self.categories.joined(separator: ", ")
                
            }
            
        }
        
    }
    
    func searchBusinesses(_ lat: Double, _ long: Double, completetionHandler: @escaping (Bool) -> Void) {
        
        let headers: HTTPHeaders = ["Authorization": "Bearer Y43yqZUkj6vah5sgOHU-1PFN2qpapJsSwXZYScYTo0-nK9w5Y3lDvrdRJeG1IpQAADep0GrRL5ZDv6ybln03nIVzP7BL_IzAf_s7Wj5_QLPOO6oXns-nJe3-kIPiWHYx"]
        
        var url = ""
        
        switch self.selectedCategory {
        case "All Types":
            
            url = "https://api.yelp.com/v3/businesses/search?latitude=\(lat)&longitude=\(long)&limit=50"
            
        default:
            
            url = "https://api.yelp.com/v3/businesses/search?latitude=\(lat)&longitude=\(long)&limit=50&categories=\(selectedCategory.lowercased())"
            
        }
        
        var name = String()
        var website = String()
        var imageURL = String()
        var rating = Int()
        var priceRange = String()
        var phone = String()
        var id = String()
        var closedBool = Bool()
        var restaurantCategory = String()
        var reviewCount = Int()
        var distance = Double()
        
        var city = String()
        var country = String()
        var state = String()
        var address = String()
        var zipCode = String()
        
        var transactions = [String]()
        
        var restaurantHoursToAppend = [RestaurantHours]()
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                
                let json = JSON(value)
                
                for business in json["businesses"].arrayValue {
                    
                    name = business["name"].stringValue
                    website = business["url"].stringValue
                    imageURL = business["image_url"].stringValue
                    rating = business["rating"].intValue
                    priceRange = business["price"].stringValue
                    phone = business["phone"].stringValue
                    id = business["id"].stringValue
                    closedBool = business["is_closed"].boolValue
                    reviewCount = business["review_count"].intValue
                    distance = business["distance"].doubleValue
                    
                    city = business["location"]["city"].stringValue
                    country = business["location"]["country"].stringValue
                    state = business["location"]["state"].stringValue
                    address = business["location"]["address1"].stringValue
                    zipCode = business["location"]["zip_code"].stringValue
                    
                    transactions = business["transactions"].arrayValue.map( { $0.string! } )
                    
                    restaurantHoursToAppend = [RestaurantHours]()
                    
                    self.showBusinessDetails(id, completionHandler: { (arr) in
                      
                        if !(arr.isEmpty) {
                            
                            restaurantHoursToAppend = arr
                            
                        }
                    })
                    
                    for category in business["categories"].arrayValue {
                        
                        restaurantCategory = category["title"].stringValue
                        
                    }
                    
                    let newRestaurant = Restaurantt(name: name, website: website, imageURL: imageURL, rating: rating, priceRange: priceRange, phone: phone, id: id, isClosed: closedBool, category: restaurantCategory, reviewCount: reviewCount, distance: distance, city: city, country: country, state: state, address: address, zipCode: zipCode, transactions: transactions)
                    self.restaurantss.append(newRestaurant)
                    
                }
                
                completetionHandler(true)
                
            } else {
                
                completetionHandler(false)
                
            }
            
        }
        
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
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

 
