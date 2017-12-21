//
//  AddTVShowVC.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 1/26/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class AddTVShowVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tvShowImg: UIImageView!
    @IBOutlet weak var tvShowTitleLbl: UILabel!
    @IBOutlet weak var tvShowPlotLbl: UILabel!
    @IBOutlet weak var tvShowRatedLbl: UILabel!
    @IBOutlet weak var tvShowStartTimeLbl: UILabel!
    @IBOutlet weak var tvShowStatusLbl: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trackShowBtn: RoundedBtn!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var plotLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    var startDay: String!
    var userInput: String!
    var finalInput: String!
    var imageURL: String?
    var timeStd: String!
    
    var showSearched: Bool = false
    var showNotFound: Bool = false
    
    var progressHUD: ProgressHUD!
    
    var tvShow: TVShow!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 40.0 / 255.0, green: 192.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        progressHUD = ProgressHUD(text: "Searching...")

        searchTextField.delegate = self
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTVShowVC.dismissKeyboard(_:)))
        scrollView.addGestureRecognizer(tapGesture)
        
        let imageView: UIImageView = UIImageView.init(image: UIImage(named: "Search"))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        let titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkScreenSizeForScroll()
    }
    
    func checkScreenSizeForScroll() {
        
        if UIScreen.main.bounds.size.height >= 568 {

            scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64)
            scrollView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64)
        } else {

            scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + 64)
            if UIDevice.current.systemVersion.hasPrefix("7") {
                scrollView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.size.width, height: self.view.bounds.height - 64)
            } else {
                scrollView.frame = CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: self.view.bounds.height - 64)
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        searchTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trackShowBtnPressed(_ sender: AnyObject) {
        
        if showSearched == true {
            if let title = tvShowTitleLbl.text, let plot = tvShowPlotLbl.text {
                let app = UIApplication.shared.delegate as! AppDelegate
                let context = app.managedObjectContext
                let entity = NSEntityDescription.entity(forEntityName: "TVShow", in:context)!
                let tvShow = TVShow(entity: entity, insertInto: context)
                tvShow.title = title
                tvShow.plot = plot
                tvShow.startTime = tvShowStartTimeLbl.text
                tvShow.setMovieImage(tvShowImg.image!)
                tvShow.rated = tvShowRatedLbl.text
                tvShow.imgUrl = imageURL
                tvShow.day = startDay
                
                context.insert(tvShow)
                
                do {
                    try context.save()
                } catch {
                    print("Could not save movie")
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                print("No show found")
            }
        }
        

    }
    
    
    func downloadTVShowInfo() {
        
        let url = URL(string: "http://api.tvmaze.com/singlesearch/shows?q=\(finalInput)")!
        Alamofire.request(.GET, url).responseJSON { (response) -> Void in
            let result = response.result
            
            if response.result.value == nil {
                print("No Data Found for show")
                self.titleLbl.isHidden = false
                self.titleLbl.text = "Show Not Found"
                self.showNotFound = true
                self.trackShowBtn.isHidden = true
                self.progressHUD.removeFromSuperview()
            }
            
            if let json = result.value as? Dictionary<String, AnyObject> {
                
                self.trackShowBtn.isHidden = false
                self.progressHUD.removeFromSuperview()
                
                if let name = json["name"] as? String {
                    
                    self.titleLbl.isHidden = false
                    self.tvShowTitleLbl.text = name
                }
                
                if let stat = json["status"] as? String {
        
                    self.statusLbl.isHidden = false
                    self.tvShowStatusLbl.text = stat
                    
                    if stat == "Running" {
                        self.tvShowStatusLbl.textColor = UIColor.white
                    } else {
                        self.tvShowStatusLbl.textColor = UIColor(red: 255.0 / 255.0, green: 50.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
                    }
                }
                
                if let summary = json["summary"] as? String {
                    let plot = summary.replacingOccurrences(of: "<[^>]+>", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
                    
                    self.plotLbl.isHidden = false
                    self.tvShowPlotLbl.text = plot
                }
                
                if let rating = json["rating"] as? Dictionary<String, AnyObject> {
                    
                    if let average = rating["average"] as? Int {
                        self.ratingLbl.isHidden = false
                        self.tvShowRatedLbl.text = "\(average)"
                    }
                }
                
                if let schedule = json["schedule"] as? Dictionary<String, AnyObject> {
                    
                    if let time = schedule["time"] as? String {
                        let startTime = time
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        if let date = dateFormatter.date(from: startTime) {
                            dateFormatter.dateFormat = "h:mm a"
                            self.timeStd = dateFormatter.string(from: date)
                            self.startTimeLbl.isHidden = false
                            self.tvShowStartTimeLbl.text = "\(self.timeStd)"
                        } else {
                            self.startTimeLbl.isHidden = false
                            self.tvShowStartTimeLbl.text = "Unknown"
                        }


                    }
                    
                    if let days = schedule["days"] as? [String] {
                        
                        if days.count > 0 {
                            self.startDay = days[0]
                        } else {
                            print("No days retrieved")
                        }
                        
                    }
                }
                
                if let bgImg = json["image"] as? Dictionary<String, AnyObject> {
                    
                    if let original = bgImg["original"] as? String {
                        self.imageURL = original
                        
                        if let url = URL(string: "\(original)") {
                            if let data = try? Data(contentsOf: url) {
                                self.tvShowImg.image = UIImage(data: data)

                            }
                        }
                        
                    }
                }
                
            }
        }
    }
    
    func clearScreen() {
        self.searchTextField.endEditing(true)
        self.searchTextField.text = ""
        self.tvShowImg.image = nil
        self.tvShowPlotLbl.text = ""
        self.tvShowRatedLbl.text = ""
        self.tvShowStatusLbl.text = ""
        self.tvShowTitleLbl.text = ""
        self.tvShowStartTimeLbl.text = ""
        self.titleLbl.text = "Title"
        self.titleLbl.isHidden = true
        self.plotLbl.isHidden = true
        self.ratingLbl.isHidden = true
        self.startTimeLbl.isHidden = true
        self.statusLbl.isHidden = true
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userInput = searchTextField.text
        finalInput = userInput.replacingOccurrences(of: " ", with: "+")
        finalInput.capitalized
        downloadTVShowInfo()
        showSearched = true
        clearScreen()
        
        self.view.addSubview(progressHUD)
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTextField.resignFirstResponder()
    }
    
    func dismissKeyboard(_ tap: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
}
