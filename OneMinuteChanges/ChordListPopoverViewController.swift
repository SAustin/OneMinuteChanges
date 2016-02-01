//
//  ChordListPopoverViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/29/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol ChordListPopoverDelegate
{
    func chordWasSelected(theChord: Chord)
}

class ChordListPopoverViewController: UITableViewController, UIPopoverPresentationControllerDelegate
{
    var chordListPopoverDelegate: ChordListPopoverDelegate?
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)!
        self.modalPresentationStyle = .Popover
        self.popoverPresentationController?.delegate = self
    }
    
    override init(style: UITableViewStyle)
    {
        super.init(style: style)
        self.modalPresentationStyle = .Popover
        self.popoverPresentationController?.delegate = self

    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ((UIApplication.sharedApplication().delegate as! AppDelegate).chordList?.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ChordListPopoverCell")
        cell?.textLabel?.text = (UIApplication.sharedApplication().delegate as! AppDelegate).chordList?[atIndexPath.row].name
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        self.chordListPopoverDelegate?.chordWasSelected((appDelegate.chordList?[indexPath.row])!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}