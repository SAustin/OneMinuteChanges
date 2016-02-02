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
    func chordSequenceWasSelected(chordSequence: [(Chord, Chord)])
    func singleChordWasSelected(chord: Chord)
}

class ChordSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChordListPopoverDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet var selectionTypeSwitch: UISegmentedControl?
    @IBOutlet var numberOfChordTextField: UITextField?
    @IBOutlet var stepper: UIStepper?
    @IBOutlet var chordListTable: UITableView?
    
    var randomSelectionList = [Chord]()
    var selectedSelectionList = [(Chord, Chord)]()
    var chordSelectionDelegate: ChordSelectionDelegate?
    
    var currentRecommendation: Recommendation?
    var currentRowSelection = 0
    var currentButtonSelection = 0
    
    var blankChord: Chord?
    
    var selectionIsRandom: Bool = false
    
    override func viewDidLoad()
    {
        self.blankChord = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.getEntity("Chord", withKey: "name", andValue: "--") as? Chord
    }
    
    func chordSelectionWasPressed(sender: UIButton)
    {
        
        //TODO: Present popover
        self.currentButtonSelection = sender.tag % 2
        self.currentRowSelection = Int(sender.tag / 100)
        
        let popover = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChordListPopoverViewController") as! ChordListPopoverViewController
        popover.modalPresentationStyle = .Popover
        popover.chordListPopoverDelegate = self
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.sourceView = sender
        popover.popoverPresentationController?.sourceRect = sender.frame
        popover.popoverPresentationController?.permittedArrowDirections = .Any
        popover.preferredContentSize = CGSizeMake(90, 440)
        
        self.presentViewController(popover, animated: true, completion: nil)
    }

    // MARK: - PopoverControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }

    
    //MARK: - Chord list Popover delegate
    func chordWasSelected(theChord: Chord)
    {
        let cell = self.tableView(self.chordListTable!, cellForRowAtIndexPath: NSIndexPath(forRow: self.currentRowSelection, inSection: 0))
        
        if self.selectedSelectionList.count <= self.currentRowSelection
        {
            self.selectedSelectionList.append((self.blankChord!, self.blankChord!))
        }
        var (chord1, chord2) = self.selectedSelectionList[self.currentRowSelection]
        
        switch self.currentButtonSelection
        {
        case 0:
            (cell as! SpecificPairCell).firstChord?.setTitle(theChord.name!, forState: .Normal)
            chord1 = theChord
        case 1:
            (cell as! SpecificPairCell).secondChord?.setTitle(theChord.name!, forState: .Normal)
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
                return ((UIApplication.sharedApplication().delegate as! AppDelegate).chordList?.count)!
            case 1:
                return self.selectedSelectionList.count + 1
            case 2:
                return Recommendation.Count.rawValue
            default:
                return 0
            }
        }
        else
        {
            return ((UIApplication.sharedApplication().delegate as! AppDelegate).chordList?.count)!
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
            (cell as! RandomChordCell).chordNameLabel?.text = appDelegate.chordList?[atIndexPath.row].name!
            
            if self.randomSelectionList.contains((appDelegate.chordList?[atIndexPath.row])!)
            {
                cell.accessoryType = .Checkmark
            }
            else
            {
                cell.accessoryType = .None
            }
            
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

                (cell as! SpecificPairCell).firstChord?.setTitle(chord1.name!, forState: .Normal)
                (cell as! SpecificPairCell).secondChord?.setTitle(chord2.name!, forState: .Normal)
            }
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("RandomChordCell", forIndexPath: atIndexPath)
            (cell as! RandomChordCell).chordNameLabel?.text = Recommendation(rawValue: atIndexPath.row)?.description()

            if let recommendation = self.currentRecommendation
            {
                if recommendation == Recommendation(rawValue: atIndexPath.row)
                {
                    cell.accessoryType = .Checkmark
                }
                else
                {
                    cell.accessoryType = .None
                }
                
            }
            else
            {
                cell.accessoryType = .None
            }

        default:
            cell = tableView.dequeueReusableCellWithIdentifier("RandomChordCell")!
            NSLog("Someone changed the switch!")
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        switch self.selectionTypeSwitch!.selectedSegmentIndex
        {
        case 0:
            if self.randomSelectionList.contains((appDelegate.chordList?[indexPath.row])!)
            {
                self.randomSelectionList.removeAtIndex(self.randomSelectionList.indexOf((appDelegate.chordList?[indexPath.row])!)!)
            }
            else
            {
                self.randomSelectionList.append((appDelegate.chordList?[indexPath.row])!)
            }
            
        case 1:
            NSLog("Do nothing")
        case 2:
            if let _ = self.currentRecommendation
            {
                if self.currentRecommendation! == Recommendation(rawValue: indexPath.row)
                {
                    self.currentRecommendation = nil
                }
                else
                {
                    self.currentRecommendation = Recommendation(rawValue: indexPath.row)
                }
            }
            else
            {
                self.currentRecommendation = Recommendation(rawValue: indexPath.row)
            }
        default:
            NSLog("Do nothing")
        }
        
        
        tableView.reloadData()
    }
    
    @IBAction func doneWasPressed(sender: UIBarButtonItem)
    {
        if self.randomSelectionList.count > 1
        {
            self.chordSelectionDelegate?.randomChordsWereSelected(self.randomSelectionList)
        }
        else if self.randomSelectionList.count == 1
        {
            self.chordSelectionDelegate?.singleChordWasSelected(self.randomSelectionList[0])
        }
        else if self.selectedSelectionList.count > 0
        {
            var returnArray = [(Chord, Chord)]()
            for (chord1, chord2) in self.selectedSelectionList
            {
                if chord1 != self.blankChord &&
                   chord2 != self.blankChord
                {
                    returnArray.append((chord1, chord2))
                }
            }
            self.chordSelectionDelegate?.chordSequenceWasSelected(returnArray)
        }
        else if let recommendation = self.currentRecommendation
        {
            if let sequence = recommendation.getSequence()
            {
                self.chordSelectionDelegate?.chordSequenceWasSelected(sequence)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}