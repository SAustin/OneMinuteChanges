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

enum CellType: Int
{
    case TrueFalse = 0
    case Action
    case NumericChoice
    
    func cellIdentifier() -> String
    {
        switch self
        {
        case .TrueFalse:
            return "SettingsTrueFalseCell"
        case .Action:
            return "SettingsActionCell"
        case .NumericChoice:
            return "SettingsNumericCell"
        }
    }
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
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
    
    @IBOutlet var tableView: UITableView?
    var products = [SKProduct]()
    
    var settingsOptions = [ [("iCloud Sync", CellType.TrueFalse), ("Unlock Extra Features", CellType.Action), ("Restore Purhases", CellType.Action)],
                            [("Allow Rotation", CellType.TrueFalse), ("Timer Length", CellType.NumericChoice), ("Practice Reminders", CellType.TrueFalse), ("Automatic Counting", CellType.TrueFalse)],
                            [("Send Feedback", CellType.Action), ("Rate the App", CellType.Action), ("About", CellType.Action)]]
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
    }
    
    @IBAction func doneWasPressed(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func reload()
    {
        products = []
        self.tableView!.reloadData()
        Products.store.requestProductsWithCompletionHandler
        {
            success, products in
            
            if success
            {
                self.products = products
                self.tableView!.reloadData()
            }
            
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
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.settingsOptions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.settingsOptions[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return ""
        case 1:
            return "Behavior"
        case 2:
            return "Feedback"
        default:
            return ""
        }
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let (cellText, cellType) = self.settingsOptions[atIndexPath.section][atIndexPath.row]
        
        let cell = self.tableView!.dequeueReusableCellWithIdentifier(cellType.cellIdentifier())

        switch cellType
        {
        case .TrueFalse:
            (cell as! SettingsTrueFalseCell).settingText?.text = cellText
            (cell as! SettingsTrueFalseCell).settingValue?.setOn(NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAutomaticCounting), animated: false)
        case .Action:
            (cell as! SettingsActionCell).settingText?.text = cellText
            (cell as! SettingsActionCell).additionalInfoText?.text = ""
            cell?.accessoryType = .DisclosureIndicator
        case .NumericChoice:
            (cell as! SettingsNumericCell).settingText?.text = cellText
            (cell as! SettingsNumericCell).settingValue?.text = "\(NSUserDefaults.standardUserDefaults().integerForKey(kSettingsTimerLength))"
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }

}