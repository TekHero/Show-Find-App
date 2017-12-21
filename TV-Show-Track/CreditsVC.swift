//
//  CreditsVC.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 2/5/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit

class CreditsVC: UIViewController {
    
    @IBOutlet weak var myLbl: UILabel!
    @IBOutlet weak var menuBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 200
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func openUrl1(_ sender: UIButton) {
        if let url = URL(string: "http://thenounproject.com/") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func openUrl2(_ sender: UIButton) {
        if let url = URL(string: "http://www.freepik.com/") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func openUrl3(_ sender: UIButton) {
        if let url = URL(string: "http://www.flaticon.com/") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func openUrl4(_ sender: UIButton) {
        if let url = URL(string: "http://www.tvmaze.com/") {
            UIApplication.shared.openURL(url)
        }
    }

}
