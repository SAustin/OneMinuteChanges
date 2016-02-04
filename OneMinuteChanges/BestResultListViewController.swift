//
//  BestResultListViewController.swift
//  OneMinuteChanges
//
//  Created by Brittany Austin on 2/3/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

class BestResultListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var baseChord: Chord?
    var resultList = [(Chord, Chord, Int)]()
    @IBOutlet var navItem: UINavigationItem?
    
    override func viewDidLoad()
    {
        self.navItem!.title = self.baseChord!.name! + " Top Scores"
        
        let dataHelper = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper
        let allChords = dataHelper.getAllChords("name")
        
        for secondChord in allChords!
        {
            if secondChord.name != self.baseChord?.name
            {
                let result = dataHelper.getBestResultFor(self.baseChord!, chord2: secondChord)
                if let _ = result
                {
                    resultList.append((self.baseChord!, secondChord, result!.score!.integerValue))
                }
                else
                {
                    resultList.append((self.baseChord!, secondChord, -1))
                }

            }
        }
        
    }
    
    @IBAction func backWasPressed(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ((UIApplication.sharedApplication().delegate as! AppDelegate).chordList?.count)! - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultListCell") as! ResultListCell
        let (_, secondChord, score) = self.resultList[atIndexPath.row]

        cell.firstChordLabel?.text = self.baseChord?.name
        cell.secondChordLabel?.text = secondChord.name
        cell.scoreLabel?.text = score >= 0 ? "\(score)" : "--"
    
        cell.backgroundColor = getScoreColor(score)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //Do nothing.
    }

}
