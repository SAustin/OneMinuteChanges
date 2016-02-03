//
//  ScoreViewController.swift
//  OneMinuteChanges
//
//  Created by Brittany Austin on 2/3/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

class ScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var chordToDisplay: Chord?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        switch segue.identifier!
        {
        case "ResultListSegue":
            let controller = segue.destinationViewController as! BestResultListViewController
            controller.baseChord = self.chordToDisplay
        default:
            NSLog("Weird segue in Score View Controller.")
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ((UIApplication.sharedApplication().delegate as! AppDelegate).chordList?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChordListPopoverCell")
        cell?.textLabel?.text = (UIApplication.sharedApplication().delegate as! AppDelegate).chordList?[atIndexPath.row].name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.chordToDisplay = (UIApplication.sharedApplication().delegate as! AppDelegate).chordList?[indexPath.row]
    }

}