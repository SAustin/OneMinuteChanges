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

class ChordListPopoverViewController: UITableViewController
{
    var chordListPopoverDelegate: ChordListPopoverDelegate?
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Chord.Count.rawValue
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ChordListPopoverCell")
        cell?.textLabel?.text = Chord(rawValue: atIndexPath.row)?.description()
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.chordListPopoverDelegate?.chordWasSelected(Chord(rawValue: indexPath.row)!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}