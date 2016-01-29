//
//  ChordSelectionViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/27/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol ChordSelectionDelegate
{
    func randomChordsWereSelected(chordList: [Chord])
}

class ChordSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var selectionTypeSwitch: UISegmentedControl?
    @IBOutlet var numberOfChordTextField: UITextField?
    @IBOutlet var stepper: UIStepper?
    @IBOutlet var chordListTable: UITableView?
    var selectionList = [Chord]()
    var chordSelectionDelegate: ChordSelectionDelegate?
    
    var selectionIsRandom: Bool = false
    
    override func viewDidLoad()
    {
        
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Chord.Count.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("RandomChordCell", forIndexPath: atIndexPath) as! RandomChordCell
        cell.chordNameLabel?.text = Chord(rawValue: atIndexPath.row)?.description()
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if self.selectionList.contains(Chord(rawValue: indexPath.row)!)
        {
            self.selectionList.removeAtIndex(self.selectionList.indexOf(Chord(rawValue: indexPath.row)!)!)
            cell.selected = false
            cell.accessoryType = .None
        }
        else
        {
            self.selectionList.append(Chord(rawValue: indexPath.row)!)
            cell.selected = true
            cell.accessoryType = .Checkmark
        }
    }
    
    @IBAction func doneWasPressed(sender: UIBarButtonItem)
    {
        if self.selectionList.count > 0
        {
            self.chordSelectionDelegate?.randomChordsWereSelected(self.selectionList)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}