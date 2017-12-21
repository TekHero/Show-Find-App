//
//  TVShowCell.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 1/26/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit
import Alamofire

class TVShowCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var plotLbl: UILabel!
    @IBOutlet weak var showDay: UILabel!
    @IBOutlet weak var backgroundColorView: UIView!
    
    var request: Request!
    var tvShow: TVShow!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundImg.clipsToBounds = true
    }
    
    func configureCell(_ tvShow: TVShow, img: UIImage?) {
        self.tvShow = tvShow

        self.titleLbl.text = tvShow.title
        self.plotLbl.text = tvShow.plot
        
        if tvShow.startTime != nil {
            self.startTimeLbl.text = tvShow.startTime
        } else {
            self.startTimeLbl.text = "Unknown"
        }
        
        
        if tvShow.day != nil {
            self.showDay.text = tvShow.day
        } else {
            self.showDay.text = "Unknown"
        }
        
        self.updateCellBgColor()
        
        if tvShow.imgUrl != nil {
            
            if img != nil {
                self.backgroundImg.image = img
            } else {
                request = Alamofire.request(.GET, tvShow.imgUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.backgroundImg.image = img

                        ViewController.imageCache.setObject(img, forKey: tvShow.imgUrl!)
                    }
                })
            }
        } else {
            self.backgroundImg.isHidden = true
        }
        
    }
    
    func updateCellBgColor() {
        if tvShow.day == "Sunday" {
            if ViewController.currentDay == 1 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        if tvShow.day == "Monday" {
            if ViewController.currentDay == 2 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        if tvShow.day == "Tuesday" {
            if ViewController.currentDay == 3 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        if tvShow.day == "Wednesday" {
            if ViewController.currentDay == 4 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        if tvShow.day == "Thursday" {
            if ViewController.currentDay == 5 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        if tvShow.day == "Friday" {
            if ViewController.currentDay == 6 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        if tvShow.day == "Saturday" {
            if ViewController.currentDay == 7 {
                self.showDay.textColor = UIColor.green
            } else {
                self.showDay.textColor = UIColor.white
            }
        }
        
        if tvShow.day == nil {
            self.showDay.textColor = UIColor.white
        }
    }
    

}
