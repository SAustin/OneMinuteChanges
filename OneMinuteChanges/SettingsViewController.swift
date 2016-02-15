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
import MessageUI

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

protocol SettingsViewControllerDelegate
{
    func settingsWereUpdated(settingsWereUpdated: Bool)
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // priceFormatter is used to show proper, localized currency
    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    @IBOutlet var tableView: UITableView?
    var activeTextField: UITextField?
    var products = [SKProduct]()
    
    var settingsViewControllerDelegate: SettingsViewControllerDelegate?
    
    var settingsOptions = [ [("iCloud Sync", CellType.TrueFalse, kSettingsiCloudSync), ("Unlock Extra Features", CellType.Action, kSettingsAdditionalFeaturesUnlocked), ("Restore Purchases", CellType.Action, "")],
                            [("Allow Rotation", CellType.TrueFalse, kSettingsAllowRotation), ("Timer Length", CellType.NumericChoice, kSettingsTimerLength), ("Practice Reminders", CellType.TrueFalse, kSettingsReminder), ("Automatic Counting", CellType.TrueFalse, kSettingsAutomaticCounting)],
                            [("Send Feedback", CellType.Action, ""), ("Rate the App", CellType.Action, ""), ("About", CellType.Action, "")]]
    
    override func viewDidLoad()
    {
        reload()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
    }
    
    @IBAction func viewTapped(sender: AnyObject)
    {
        self.activeTextField?.resignFirstResponder()
    }

    func textFieldWasTapped(sender: UITextField)
    {
        self.activeTextField = sender
    }
    
    @IBAction func doneWasPressed(sender: UIBarButtonItem)
    {
        //TODO: Be less lazy.
        self.settingsViewControllerDelegate?.settingsWereUpdated(true)
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

    
    func restorePurchases()
    {
        Products.store.restoreCompletedTransactions()
    }
    
    @IBAction func purchaseProduct()
    {
        let product = self.products[0]
        Products.store.purchaseProduct(product)
    }
    
    func productPurchased(notification: NSNotification)
    {
        //let productIdentifier = notification.object as! String
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kSettingsAdditionalFeaturesUnlocked)
        self.tableView?.reloadData()
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
        let (cellText, cellType, defaultsValue) = self.settingsOptions[indexPath.section][indexPath.row]
        
        let cell = self.tableView!.dequeueReusableCellWithIdentifier(cellType.cellIdentifier())
        let tagValue = 100*indexPath.section + indexPath.row
        
        switch cellType
        {
        case .TrueFalse:
            (cell as! SettingsTrueFalseCell).settingText?.text = cellText
            (cell as! SettingsTrueFalseCell).settingValue?.setOn(NSUserDefaults.standardUserDefaults().boolForKey(defaultsValue), animated: false)
            (cell as! SettingsTrueFalseCell).settingValue?.tag = tagValue
            (cell as! SettingsTrueFalseCell).settingValue?.addTarget(self, action: "switchWasFlipped:", forControlEvents: .ValueChanged)
        case .Action:
            (cell as! SettingsActionCell).settingText?.text = cellText
            
            if defaultsValue == kSettingsAdditionalFeaturesUnlocked
            {
                if !NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked) && SKPaymentQueue.canMakePayments()
                {
                    //TODO: Localize.
                    if self.products.count > 0
                    {
                        (cell as! SettingsActionCell).additionalInfoText?.text = priceFormatter.stringFromNumber(self.products[0].price)
                    }
                    else
                    {
                        (cell as! SettingsActionCell).additionalInfoText?.text = "--"
                    }
                    cell?.accessoryType = .DisclosureIndicator
                    
                }
                else if !NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked) && !SKPaymentQueue.canMakePayments()
                {
                    (cell as! SettingsActionCell).additionalInfoText?.text = "Unavailable"
                    cell?.accessoryType = .DisclosureIndicator
                }
                else if NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked)
                {
                    (cell as! SettingsActionCell).additionalInfoText?.text = "Unlocked"
                    (cell as! SettingsActionCell).accessoryType = .None
                }
            }
            else
            {
                (cell as! SettingsActionCell).additionalInfoText?.text = ""
                cell?.accessoryType = .DisclosureIndicator
            }
            
            
        case .NumericChoice:
            (cell as! SettingsNumericCell).settingText?.text = cellText
            (cell as! SettingsNumericCell).settingValue?.text = "\(NSUserDefaults.standardUserDefaults().integerForKey(defaultsValue))"
            (cell as! SettingsNumericCell).settingValue?.tag = tagValue
            (cell as! SettingsNumericCell).settingValue?.delegate = self
        }
        
        return cell!

    }
    
    func switchWasFlipped(sender: UISwitch)
    {
        let (_, _, defaultsValue) = self.settingsOptions[Int(sender.tag / 100)][sender.tag % 100]
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: defaultsValue)
        
        switch defaultsValue
        {
        case kSettingsReminder:
            if sender.on
            {
                //Schedule reminders
                let notification = UILocalNotification()
                notification.alertTitle = "Practice Reminder"
                notification.alertBody = "Don't forget to practice chord changes today!"
                
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.fireDate = NSDate().dateByAddingTimeInterval(20)
                notification.repeatInterval = NSCalendarUnit.Day
                notification.category = "OneMinuteChanges"
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            else
            {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }

        default:
            NSLog("do nothing")
        }
        
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let (cellText, _, defaultsValue) = self.settingsOptions[indexPath.section][indexPath.row]
        
        if defaultsValue == kSettingsAdditionalFeaturesUnlocked
        {
            if !NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked) && SKPaymentQueue.canMakePayments()
            {
                self.purchaseProduct()
            }
            else if !NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked) && !SKPaymentQueue.canMakePayments()
            {
                let alert = UIAlertController(title: "Error", message: "In app purchases must be enabled in device settings to unlock additional features.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
            }
            else if NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked)
            {
                self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
            }

        }
        else if cellText == "Restore Purchases"
        {
            self.restorePurchases()
        }
        else if cellText == "Send Feedback"
        {
            if !MFMailComposeViewController.canSendMail()
            {
                let alert = UIAlertController(title: "Error", message: "This device must be set up to send email in order to send feedback.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
            }
            else
            {
                let composeViewer = MFMailComposeViewController()
                composeViewer.mailComposeDelegate = self
                
                composeViewer.setToRecipients(["scott.austin7@gmail.com"])
                composeViewer.setSubject("1 Minute Changes Feedback")
                
                self.presentViewController(composeViewer, animated: true, completion: nil)
            }
            
            
        }
        else
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}

extension SettingsViewController: MFMailComposeViewControllerDelegate
{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: UITextFieldDelegate
{
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        NSUserDefaults.standardUserDefaults().setInteger((Int(textField.text!)!), forKey: kSettingsTimerLength)
    }
}