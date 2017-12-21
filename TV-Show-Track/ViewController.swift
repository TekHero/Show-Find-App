//
//  ViewController.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 1/26/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import iAd

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADInterstitialDelegate, ADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
    static var currentDay: Int!
    
    let defaults = UserDefaults.standard
    
    var tvShows = [TVShow]()
    var refreshControl:UIRefreshControl!
    var showTitle: String!
    var showStartingTime: String!
    var showBgImage: UIImage!
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.bool(forKey: "purchased") == true {
            print("No Ads, IAP was purchased")
        }
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.interstitial = createAndLoadInterstitial()
        
        let request = GADRequest()
        request.testDevices = ["4dd07992bd9693bc9898583c89091535"]
        self.interstitial.load(request)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 40.0 / 255.0, green: 192.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 200
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let imageView: UIImageView = UIImageView.init(image: UIImage(named: "ShowFind"))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        let titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView
        
        
        let imgView: UIImageView = UIImageView.init(image: UIImage(named: "one-scene"))
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        tableView.backgroundView = imgView
        imgView.reloadInputViews()
        
        setupNotificationSettings()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchAndSetRequests()
        getTodaysDay()
        animateTable()
        checkAd()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6536902852765774/6715987841")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        self.interstitial = createAndLoadInterstitial()
    }
    
    func checkAd() {
        
        if (defaults.bool(forKey: "purchased") == false) {
            
            if self.interstitial.isReady {
                let rNumber1 = arc4random() % 46 + 1
                let rNumber2 = arc4random() % 46 + 1
                if rNumber1 % 2 == 1 && rNumber2 % 1 == 0 {
                    
                    self.interstitial.present(fromRootViewController: self)
                }
            }
        } else {
            print("IAP Purchased, no more ads")
        }
        
        
    }
    
    
    func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func fetchAndSetRequests() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TVShow")
        
        do {
            let results = try context.fetch(fetchRequest)
            self.tvShows = results as! [TVShow]
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath) as! TVShowCell
        
        if currentCell.startTimeLbl.text != "Unknown" {
            showStartingTime = currentCell.startTimeLbl.text
        } else {
            showStartingTime = "Time Unknown"
        }
        
        showTitle = currentCell.titleLbl.text
        showBgImage = currentCell.backgroundImg.image
        
        performSegue(withIdentifier: "NotificationSetupVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.managedObjectContext
            
            context.delete(tvShows[indexPath.row] as NSManagedObject)
            tvShows.remove(at: indexPath.row)
            
            do {
                try context.save()
            } catch let err as NSError {
                print(err.debugDescription)
            }
            
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tvShow = tvShows[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TVShowCell") as? TVShowCell {
            
            var img: UIImage?
            if let url = tvShow.imgUrl {
                img = ViewController.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            cell.configureCell(tvShow, img: img)
            
            return cell
            
        } else {

            return TVShowCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = tvShows[sourceIndexPath.row]
        tvShows.remove(at: sourceIndexPath.row)
        tvShows.insert(itemToMove, at: destinationIndexPath.row)
        
        let defaults = UserDefaults.standard
        defaults.set(tvShows, forKey: "tvShowArray")
    }
    
    
    func getTodaysDay() {
        let date = Date()
        let calendar = Calendar.current
        let dateComponents = (calendar as NSCalendar).components([.weekday], from: date)
        
        ViewController.currentDay = dateComponents.weekday
    }
    
    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight:CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: TVShowCell = i as! TVShowCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: TVShowCell = a as! TVShowCell
            UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                
                }, completion: nil)
            
            index += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NotificationSetupVC" {
            let notifVC = segue.destination as! NotificationSetupVC
            notifVC.time = showStartingTime
            notifVC.showTitle = showTitle
            notifVC.showImage = showBgImage
            notifVC.showTime = showStartingTime
        }
    }
    
    @IBAction func startEditing(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing {
            // Tableview.editing = false
            tableView.setEditing(false, animated: true)
            editBtn.style = UIBarButtonItemStyle.plain
            editBtn.title = "Edit"
            
        } else {
            // Tableview.editing = true
            tableView.setEditing(true, animated: true)
            editBtn.style = UIBarButtonItemStyle.done
            editBtn.title = "Done"
        }
    }
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.shared.currentUserNotificationSettings
        
        if (notificationSettings.types == UIUserNotificationType()) {
            // Specify the notification types
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
            
            let dismissAction = UIMutableUserNotificationAction()
            dismissAction.identifier = "Dismiss"
            dismissAction.title = "Ok, Got it!"
            dismissAction.activationMode = UIUserNotificationActivationMode.background
            dismissAction.isDestructive = false
            dismissAction.isAuthenticationRequired = false
            
            let actionsArray = NSArray(object: dismissAction)
            let actionsArrayMinimal = NSArray(object: dismissAction)
            
            // Specify the category related to the above actions.
            let tvShowReminderCategory = UIMutableUserNotificationCategory()
            tvShowReminderCategory.identifier = "tvShowReminderCategory"
            tvShowReminderCategory.setActions(actionsArray as? [UIUserNotificationAction], for: UIUserNotificationActionContext.default)
            tvShowReminderCategory.setActions(actionsArrayMinimal as? [UIUserNotificationAction], for: UIUserNotificationActionContext.minimal)
            
            let categoriesForSettings = NSSet(objects: tvShowReminderCategory)
            
            // Register the notification settings
            let newNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: categoriesForSettings as? Set<UIUserNotificationCategory>)
            UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
            
        }
        
    }
    
}

