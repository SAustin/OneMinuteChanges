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
    var randomSelectionList = [Chord]()
    var selectedSelectionList = [(Chord, Chord)]()
    var chordSelectionDelegate: ChordSelectionDelegate?
    
    var currentRowSelection = 0
    var currentButtonSelection = 0
    
    var selectionIsRandom: Bool = false
    
    override func viewDidLoad()
    {
        
    }
    
    func chordSelectionWasPressed(sender: UIButton)
    {
        //TODO: Present popover
        self.currentButtonSelection = sender.tag % 2
    }
    
    func chordWasSelected(theChord: Chord)
    {
        let cell = self.tableView(self.chordListTable!, cellForRowAtIndexPath: NSIndexPath(forRow: self.currentRowSelection, inSection: 0))
        
        if self.selectedSelectionList.count <= self.currentRowSelection
        {
            self.selectedSelectionList.append((Chord.Count, Chord.Count))
        }
        var (chord1, chord2) = self.selectedSelectionList[self.currentRowSelection]
        
        switch self.currentButtonSelection
        {
        case 0:
            (cell as! SpecificPairCell).firstChord?.setTitle(theChord.description(), forState: .Normal)
            chord1 = theChord
        case 1:
            (cell as! SpecificPairCell).secondChord?.setTitle(theChord.description(), forState: .Normal)
            chord2 = theChord
        default:
            NSLog("Inappropriate value coming across in chord selection")
        }

        self.selectedSelectionList[self.currentRowSelection] = (chord1, chord2)

        self.chordListTable?.reloadData()
    }
    
    // MARK: - UISegmentedControl
    @IBAction func segmentWasChanged(sender: UISegmentedControl)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.chordListTable?.reloadData()
        }
        
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let _ = self.selectionTypeSwitch?.selectedSegmentIndex
        {
            switch self.selectionTypeSwitch!.selectedSegmentIndex
            {
            case 0:
                return Chord.Count.rawValue
            case 1:
                return self.selectedSelectionList.count + 1
            default:
                return 0
            }
        }
        else
        {
            return Chord.Count.rawValue
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell
        
        var activeSwitch = 0
        if let switchValue = self.selectionTypeSwitch?.selectedSegmentIndex
        {
            activeSwitch = switchValue
        }
        
        switch activeSwitch
        {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("RandomChordCell", forIndexPath: atIndexPath)
            (cell as! RandomChordCell).chordNameLabel?.text = Chord(rawValue: atIndexPath.row)?.description()
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("SpecificPairCell", forIndexPath: atIndexPath)
            (cell as! SpecificPairCell).firstChord?.layer.cornerRadius = 5
            (cell as! SpecificPairCell).firstChord?.layer.borderWidth = 1
            (cell as! SpecificPairCell).firstChord?.tag = atIndexPath.row * 100
            (cell as! SpecificPairCell).firstChord?.addTarget(self, action: "chordSelectionWasPressed:", forControlEvents: .TouchUpInside)
            
            (cell as! SpecificPairCell).secondChord?.layer.cornerRadius = 5
            (cell as! SpecificPairCell).secondChord?.layer.borderWidth = 1
            (cell as! SpecificPairCell).secondChord?.tag = atIndexPath.row * 100 + 1
            (cell as! SpecificPairCell).secondChord?.addTarget(self, action: "chordSelectionWasPressed:", forControlEvents: .TouchUpInside)
            
            if atIndexPath.row == self.selectedSelectionList.count
            {
                (cell as! SpecificPairCell).firstChord?.setTitle("--", forState: .Normal)
                (cell as! SpecificPairCell).secondChord?.setTitle("--", forState: .Normal)
            }
            else
            {
                let (chord1, chord2) = self.selectedSelectionList[atIndexPath.row]
                if chord1 == .Count
                {
                    (cell as! SpecificPairCell).firstChord?.setTitle("--", forState: .Normal)
                }
                else
                {
                    (cell as! SpecificPairCell).firstChord?.setTitle(chord1.description(), forState: .Normal)
                }
                if chord2 == .Count
                {
                    (cell as! SpecificPairCell).secondChord?.setTitle("--", forState: .Normal)
                }
                else
                {
                    (cell as! SpecificPairCell).secondChord?.setTitle(chord2.description(), forState: .Normal)
                }
            }
            
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("RandomChordCell")!
            NSLog("Someone changed the switch!")
        }
        
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
        
        if self.randomSelectionList.contains(Chord(rawValue: indexPath.row)!)
        {
            self.randomSelectionList.removeAtIndex(self.randomSelectionList.indexOf(Chord(rawValue: indexPath.row)!)!)
            cell.selected = false
            cell.accessoryType = .None
        }
        else
        {
            self.randomSelectionList.append(Chord(rawValue: indexPath.row)!)
            cell.selected = true
            cell.accessoryType = .Checkmark
        }
    }
    
    @IBAction func doneWasPressed(sender: UIBarButtonItem)
    {
        if self.randomSelectionList.count > 0
        {
            self.chordSelectionDelegate?.randomChordsWereSelected(self.randomSelectionList)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}