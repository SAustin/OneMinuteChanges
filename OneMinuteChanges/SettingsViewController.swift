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
    @IBOutlet var tapButton: UIButton?
    var activeTextField: UITextField?
    var currentIndexPath: NSIndexPath?
    
    var settingsViewControllerDelegate: SettingsViewControllerDelegate?
    
    var settingsOptions = [ /*[/*("iCloud Sync", CellType.TrueFalse, kSettingsiCloudSync), */ ("Unlock Extra Features", CellType.Action, kSettingsAdditionalFeaturesUnlocked), ("Restore Purchases", CellType.Action, "")], */
                            [("Allow Rotation", CellType.TrueFalse, kSettingsAllowRotation), ("Timer Length", CellType.NumericChoice, kSettingsTimerLength), ("Practice Reminders", CellType.TrueFalse, kSettingsReminder), ("Automatic Counting", CellType.TrueFalse, kSettingsAutomaticCounting)],
                            [("Send Feedback", CellType.Action, ""), ("Please Rate 1MinuteChanges", CellType.Action, "")/*, ("About", CellType.Action, "")*/]]
    
    override func viewDidLoad()
    {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked) &&
           (globalProducts.count == 0)
        {
            reload()
        }
        
        self.view.sendSubviewToBack(self.tapButton!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchaseFailed:", name: IAPHelperTransactionFailedNotification, object: nil)
    }
    
    override func shouldAutorotate() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAllowRotation)
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
        SVProgressHUD.show()
        
        globalProducts = []
        self.tableView!.reloadData()
        Products.store.requestProductsWithCompletionHandler
        {
            success, products in
            
            if success
            {
                SVProgressHUD.dismiss()
                globalProducts = products
                self.tableView!.reloadData()
            }
            
        }
    }

    
    func restorePurchases()
    {
        Products.store.restoreCompletedTransactions()
    }
    
    func purchaseProduct()
    {
        SVProgressHUD.show()
        dispatch_async(dispatch_get_main_queue())
        {
            let product = globalProducts[0]
            Products.store.purchaseProduct(product)
        }
    }
    
    func productPurchased(notification: NSNotification)
    {
        //let productIdentifier = notification.object as! String
        SVProgressHUD.dismiss()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kSettingsAdditionalFeaturesUnlocked)
        self.tableView?.reloadData()
    }
    
    func purchaseFailed(notification: NSNotification)
    {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "Transaction Failed", message: "The in app purchased failed - please try again.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.settingsOptions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        if section == 0 && NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAdditionalFeaturesUnlocked)
//        {
//            return self.settingsOptions[section].count - 1
//        }
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
                    if globalProducts.count > 0
                    {
                        (cell as! SettingsActionCell).additionalInfoText?.text = priceFormatter.stringFromNumber(globalProducts[0].price)
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
        case kSettingsAllowRotation:
            if sender.on
            {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kSettingsAllowRotation)
            }
            else
            {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kSettingsAllowRotation)
            }
        case kSettingsReminder:
            if sender.on
            {
                //Schedule reminders
                let notification = UILocalNotification()
                notification.alertTitle = "Practice Reminder"
                notification.alertBody = "Don't forget to practice chord changes today!"
                
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.fireDate = NSDate().dateByAddingTimeInterval(60)
                notification.repeatInterval = NSCalendarUnit.Day
                notification.category = "OneMinuteChanges"
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kSettingsReminder)
            }
            else
            {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kSettingsReminder)
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }

        default:
            NSLog("do nothing")
        }
        
    }
    
    func openStoreProductWithiTunesItemIdentifier(identifier: String)
    {
        SVProgressHUD.show()
        
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
    
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : "778908544"]//identifier]
        storeViewController.loadProductWithParameters(parameters)
            {
                [weak self] (loaded, error) -> Void in
                if loaded
                {
                    SVProgressHUD.dismiss()
                    // Parent class of self is UIViewContorller
                    self?.presentViewController(storeViewController, animated: true, completion: nil)
                }
                else
                {
                    NSLog("\(error)")
                }
            }
        }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
//        case 0:
//            return "General"
        case 0:
            return "Behavior"
        case 1:
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
        self.currentIndexPath = indexPath
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
        else if cellText == "Please Rate 1MinuteChanges"
        {
            openStoreProductWithiTunesItemIdentifier("1082484217")
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        self.tableView?.deselectRowAtIndexPath(self.currentIndexPath!, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SettingsViewController: UITextFieldDelegate
{
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.activeTextField = textField
        self.view.bringSubviewToFront(self.tapButton!)
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        self.view.sendSubviewToBack(self.tapButton!)
        NSUserDefaults.standardUserDefaults().setInteger((Int(textField.text!)!), forKey: kSettingsTimerLength)
    }
}

extension SettingsViewController: SKStoreProductViewControllerDelegate
{
    func productViewControllerDidFinish(viewController: SKStoreProductViewController)
    {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}