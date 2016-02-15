//
//  SettingsViewController.swift
//  OneMinuteChanges
//
//  Created by Brittany Austin on 2/14/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewController: UITableViewController
{
    /*TODO:
     * iCloud sync Yes/No
     * Purchase Extra Features
     * Restore Purchases
     **Behavior
     * Rotation
     * Practice Length (default 1; 2, 3)
     * Notificaiton reminders to practice
     * Automatic chord Counting (when available)
     **Feedback
     * Send Feedback
     * Rate the app
     * About
     */
  // priceFormatter is used to show proper, localized currency
    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    var products = [SKProduct]()
    
    override func viewDidLoad()
    {
        // Set up a refresh control, call reload to start things up
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "reload", forControlEvents: .ValueChanged)
        reload()
        refreshControl?.beginRefreshing()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
    }

    func reload()
    {
        products = []
        tableView.reloadData()
        Products.store.requestProductsWithCompletionHandler
        {
            success, products in
            
            if success
            {
                self.products = products
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }

    
    @IBAction func restorePurchases(sender: AnyObject)
    {
        Products.store.restoreCompletedTransactions()
    }
    
    @IBAction func purchaseProduct(sender: AnyObject)
    {
        let product = self.products[0]
        Products.store.purchaseProduct(product)
    }
    
    func productPurchased(notification: NSNotification)
    {
        let productIdentifier = notification.object as! String
        for (index, product) in self.products.enumerate()
        {
            if product.productIdentifier == productIdentifier
            {
                
            }
        }
    }
}