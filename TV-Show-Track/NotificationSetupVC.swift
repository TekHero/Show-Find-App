//
//  NotificationSetupVC.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 2/1/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit

class NotificationSetupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var showTitleLbl: UILabel!
    @IBOutlet weak var showTimeLbl: UILabel!
    @IBOutlet weak var rightShowImg: UIImageView!
    @IBOutlet weak var leftShowImg: UIImageView!
    @IBOutlet weak var msgTextField: MaterialTextField!
    
    var time: String?
    var showTitle: String?
    var showTime: String?
    var notifTime: Date?
    var showImage: UIImage?
    var usersDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        msgTextField.delegate = self
        leftShowImg.clipsToBounds = true
        rightShowImg.clipsToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showTitleLbl.text = showTitle
        showTimeLbl.text = showTime
        leftShowImg.image = showImage
        rightShowImg.image = showImage
    }
    
    
    func fixNotificationDate(_ dateToFix: Date) -> Date {
        var dateComponets: DateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: dateToFix)
        
        dateComponets.second = 0
        
        let fixedDate: Date! = Calendar.current.date(from: dateComponets)
        
        return fixedDate
    }
    
    @IBAction func remindMeBtnPressed(_ sender: UIButton!) {
        
        scheduleLocalNotification()
        leftShowImg.image = nil
        rightShowImg.image = nil
        msgTextField.text = ""
        navigationController?.popToRootViewController(animated: true)
    }
    
    func scheduleLocalNotification() {
        let localNotification = UILocalNotification()
        localNotification.timeZone = TimeZone.autoupdatingCurrent
        localNotification.fireDate = fixNotificationDate(datePicker.date)
        if msgTextField.text != "" {
            localNotification.alertBody = msgTextField.text
        } else {
            localNotification.alertBody = "Hey remember, \(showTitle!) is on today!"
        }
        localNotification.alertAction = "Got It!"
        localNotification.category = "tvShowReminderCategory"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
    }
    
    // ------- Text Field Stuff ------- //
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.4)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y - 200, width: self.view.frame.size.width, height: self.view.frame.size.height)
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.4)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 200, width: self.view.frame.size.width, height: self.view.frame.size.height)
        UIView.commitAnimations()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        msgTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        msgTextField.resignFirstResponder()
    }
    

}
