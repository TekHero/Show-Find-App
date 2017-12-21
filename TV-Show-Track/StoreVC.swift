//
//  StoreVC.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 2/15/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit
import StoreKit

class StoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    let productIdentifiers = Set(["com.codebluapps.ShowTrack.RemoveAds"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        requestProductData()
        SKPaymentQueue.default().add(self)
        
        let colorView = UIView()
        colorView.backgroundColor = UIColor.clear
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let imgView: UIImageView = UIImageView.init(image: UIImage(named: "Modern-Black-Wallpaper"))
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        tableView.backgroundView = imgView
        imgView.reloadInputViews()
        
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 200
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = productsArray[indexPath.row]
        
        if defaults.bool(forKey: "purchased") == true {
            cell.purchasedLbl.isHidden = false
            cell.purchasedLbl.textColor = UIColor.green
            cell.purchasedLbl.text = "Purchased"
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.productTitleLbl.text = product.localizedTitle
        cell.productDescLbl.text = product.localizedDescription
        cell.priceLbl.text = "$\(product.price)"
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if defaults.bool(forKey: "purchased") == false {
            
            let payment = SKPayment(product: productsArray[indexPath.row])
            SKPaymentQueue.default().add(payment)
        } else {
            print("Purchased was made already")
        }
        
    }
    
    // ---------- Payment ---------- //
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func deliverProduct(_ transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "com.codebluapps.ShowTrack.RemoveAds"
        {
            print("Non-Consumable Product Purchased")
            // Unlock Feature
            defaults.set(true, forKey: "purchased")
            tableView.reloadData()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            
            for i in 0 ..< products.count {
                
                self.product = products[i]
                self.productsArray.append(product!)

            }
            
            self.tableView.reloadData()
            
        } else {
            
            print("No products found")
            
        }
        
        var invalidProducts: [String]?
        invalidProducts = response.invalidProductIdentifiers
        
        for product in invalidProducts! {
            print("Product not found: \(product)")
        }
    }
    
    func requestProductData() {
        
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                self.productIdentifiers as Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.shared.openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func restoreBtnPressed(_ sender: AnyObject) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Transactions Restored")
        
        for transaction:SKPaymentTransaction in queue.transactions {
            
            if transaction.payment.productIdentifier == "com.codebluapps.ShowTrack.RemoveAds"
            {
                print("Non-Consumable Product Purchased")
                // Unlock Feature
                defaults.set(true, forKey: "purchased")
                tableView.reloadData()
            }
        }
        
        let alertController = UIAlertController(title: "Thank You", message: "Your purchase(s) were restored", preferredStyle: UIAlertControllerStyle.alert)
        let doneAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
