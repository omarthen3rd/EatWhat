//
//  ReviewCard.swift
//  EatWhat
//
//  Created by Omar Abbasi on 2017-04-24.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ReviewCard: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var datePosted: UILabel!
    @IBOutlet var userRating: UILabel!
    @IBOutlet var reviewText: UILabel!
    
    var restaurantReview: RestaurantReview! {
        
        didSet {
            
            userImage.contentMode = .scaleAspectFill
            userImage.clipsToBounds = true
            userImage.layer.cornerRadius = 8.0
            userImage.sd_setImage(with: URL(string: restaurantReview.imageURL), placeholderImage: UIImage(named: "star"))
            userName.text = restaurantReview.name
            datePosted.text = restaurantReview.reviewDate
            userRating.text = "\(restaurantReview.rating)"
            reviewText.text = restaurantReview.review

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
        
        Bundle.main.loadNibNamed("ReviewCard", owner: self, options: nil)
        
        addSubview(contentView)
        
    }

}
