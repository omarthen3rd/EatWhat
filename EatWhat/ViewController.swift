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

struct Restaurant {
    
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
    
}

struct RestaurantReview {
    
    var name: String
    var reviewDate: String
    var review: String
    var rating: Int
    var imageURL: String
    
}

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var containerVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var vibrancyView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var noresultsLabel: UILabel!
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
        
    var snapBehavior: UISnapBehavior!
    var animator: UIDynamicAnimator!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var scrollView: UIScrollView!
    
    var locationManager = CLLocationManager()
    var locationToUse = String()
    
    var viewIsOpen = false
    var didGetLocation = false
    var didUpdateLocationCount = 0
    var newCount = 0
    
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
    var restaurants = [Restaurant]()
    var restaurantReviews = [RestaurantReview]()
    
    var restaurantIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
        
    }
    
    func loadCard(_ forward: Bool) {
        
        self.card = RestaurantCard(frame: CGRect(x: 0, y: 0, width: 343, height: 449))
        self.card.restaurant = self.restaurants[self.restaurantIndex]
        self.card.translatesAutoresizingMaskIntoConstraints = false
        
        if forward {
            
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
                
            })
            
        } else {
            
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
                
            })
            
        }
        
        if self.restaurantIndex == 0 {
            self.likeButton.isEnabled = true
            self.dislikeButton.isEnabled = false
        } else {
            self.likeButton.isEnabled = true
            self.dislikeButton.isEnabled = true
        }
        
    }
    
    func loadInterface() {
                
        dislikeButton.addTarget(self, action: #selector(self.leftTap), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(self.rightTap), for: .touchUpInside)
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
            buttonY += 40
            self.scrollView.addSubview(button)
        }
        
        scrollView.contentSize = CGSize(width: self.vibrancyView.bounds.width, height: buttonY)
                
        self.loadCard(true)
        
    }
    
    func boolToString(_ bool: Bool) -> String {
        
        if bool {
            return "Yes"
        } else {
            return "No"
        }
        
    }
    
    func returnBool(_ number: Int) -> Bool {
        
        if number == 1 {
            return true
        } else {
            return false
        }
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
    
    func loadSadView() {
        
        sadView = UIView(frame: CGRect(x: 312.5 * 0.1, y: 401 / 4, width: 312.5, height: 401))
        
        let sadText = UILabel(frame: CGRect(x: 0, y: 0, width: 312.5, height: 401))
        sadText.text = "No Results"
        sadText.textColor = UIColor.white
        sadText.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightBold)
        sadText.numberOfLines = 0
        sadText.textAlignment = .center
        
        self.likeButton.isEnabled = false
        self.dislikeButton.isEnabled = false
        
        sadView.addSubview(sadText)
        self.view.insertSubview(sadView, at: 1)
        
    }
    
    func createBanner(_ bannerText: String) -> UIView {
        
        let banner = UIView(frame: CGRect(x: 31.25, y: dislikeButton.frame.origin.y - 60, width: 312.5, height: 40))
        banner.layer.cornerRadius = 10
        banner.backgroundColor = UIColor.white
        
        let bannerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 312.5 - 15, height: 40))
        bannerLabel.text = bannerText
        bannerLabel.textAlignment = .left
        bannerLabel.numberOfLines = 1
        bannerLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        
        self.dislikeButton.isEnabled = false
        self.likeButton.isEnabled = false
        
        banner.addSubview(bannerLabel)
        
        return banner
        
    }
    
    func leftTap() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.card.center = CGPoint(x: 300, y: self.card.center.y)
            self.card.alpha = 0.0
            
        }, completion: { (success) in
            
            if self.restaurants.endIndex == self.restaurantIndex + 1 {
                
                let banner = self.createBanner("well shit it's empty")
                self.view.addSubview(banner)
                
            } else {
                
                self.card.removeFromSuperview()
                self.restaurantIndex -= 1
                
                if self.restaurants.endIndex == self.restaurantIndex {
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.loadSadView()
                        }
                    }
                } else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.loadCard(false)
                        }
                    }
                }
                
            }
            
        })
        
    }
    
    func rightTap() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.card.center = CGPoint(x: -300, y: self.card.center.y)
            self.card.alpha = 0.0
            
        }, completion: { (success) in
            
            if self.restaurants.endIndex == self.restaurantIndex + 1 {
                
                let banner = self.createBanner("well shit it's empty")
                self.view.addSubview(banner)
                self.dislikeButton.isEnabled = true
                
            } else {
                
                self.card.removeFromSuperview()
                self.restaurantIndex += 1
                
                if self.restaurants.endIndex == self.restaurantIndex {
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.loadSadView()
                        }
                    }
                } else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.loadCard(true)
                        }
                    }
                }
                
            }
            
        })
        
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
                            self.loadCard()
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
                            self.loadCard()
                        }
                    }
                }
            }
            
        } */
        
    }
    
    func handleSelectedRestaurant(_ button: UIButton, _ onlySelect: Bool = false) {
        
        if onlySelect {
            
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            button.backgroundColor = UIColor.darkGray
            
        }
        
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
        self.restaurants.removeAll()
        self.restaurantIndex = 0
        handleTap(middleButton)
        self.searchBusinesses(self.lat, self.long) { (success) in
            
            if success {
                
                if self.restaurants.isEmpty {
                    
                    self.noresultsLabel.text = "No Results"
                    self.noresultsLabel.isHidden = false
                    
                } else {
                    
                    self.noresultsLabel.text = "Loading..."
                    self.noresultsLabel.isHidden = false
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            self.noresultsLabel.isHidden = true
                            self.loadCard(true)
                        }
                    }
                    
                }
                
            } else {
                
                self.noresultsLabel.isHidden = false
                
            }
            
        }
        
    }
    
    func handleTap(_ button: UIButton) {
        
        if viewIsOpen {
            
            // close view
            
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.containerView.isHidden = true
                self.likeButton.isHidden = false
                self.dislikeButton.isHidden = false
                self.card.isHidden = false
                
            })
            
            self.viewIsOpen = false
            
        } else {
            
            // open view
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.containerView.isHidden = false
                
            }, completion: { (success) in
                
                self.view.bringSubview(toFront: self.card)
                self.card.isHidden = true
                self.dislikeButton.isHidden = true
                self.likeButton.isHidden = true
            })
            
            self.viewIsOpen = true
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // add some kind of error view telling user to allow location
        
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
            
            self.restaurants.removeAll()
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
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                
                let json = JSON(value)
                
                for business in json["businesses"].arrayValue {
                    
                    let name = business["name"].stringValue
                    let website = business["url"].stringValue
                    let imageURL = business["image_url"].stringValue
                    let rating = business["rating"].intValue
                    let priceRange = business["price"].stringValue
                    let phone = business["phone"].stringValue
                    let id = business["id"].stringValue
                    let closedBool = business["is_closed"].boolValue
                    var restaurantCategory = String()
                    let reviewCount = business["review_count"].intValue
                    let distance = business["distance"].doubleValue
                    
                    let city = business["location"]["city"].stringValue
                    let country = business["location"]["country"].stringValue
                    let state = business["location"]["state"].stringValue
                    let address = business["location"]["address1"].stringValue
                    let zipCode = business["location"]["zip_code"].stringValue
                    
                    let transactions: [String] = business["transactions"].arrayValue.map( { $0.string! } )
                    
                    for category in business["categories"].arrayValue {
                        
                        restaurantCategory = category["title"].stringValue
                        
                    }
                    
                    let newRestaurant = Restaurant(name: name, website: website, imageURL: imageURL, rating: rating, priceRange: priceRange, phone: phone, id: id, isClosed: closedBool, category: restaurantCategory, reviewCount: reviewCount, distance: distance, city: city, country: country, state: state, address: address, zipCode: zipCode, transactions: transactions)
                    self.restaurants.append(newRestaurant)
                    
                    
                }
                completetionHandler(true)
                
            } else {
                
                completetionHandler(false)
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

