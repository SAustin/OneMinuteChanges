//
//  ChordDictionaryViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 2/2/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

class ChordDictionaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var allChordList: [Chord]?
    
    override func viewDidLoad()
    {
        self.allChordList = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.getAllChords("name")
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.allChordList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        return self.configureCell(tableView, atIndexPath: indexPath)
    }
    
    func configureCell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChordDictionaryCell") as! ChordDictionaryCell
        cell.chordName?.text = allChordList![atIndexPath.row].name
        let path = NSBundle.mainBundle().pathForResource(allChordList![atIndexPath.row].fileName, ofType: "png")
        if let filePath = path
        {
            cell.chordTab?.image = UIImage(contentsOfFile: filePath)
        }

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
}