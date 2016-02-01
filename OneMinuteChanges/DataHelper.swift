//
//  DataHelper.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/30/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataHelper
{
    func getBestResultFor(chord1: Chord, chord2: Chord) -> Result?
    {
        var result: Result?
        let resultSet = (chord1.results as! Set<Result>).intersect(chord2.results as! Set<Result>)

        for currentResult in resultSet
        {
            if let _ = result
            {
                if result!.score?.integerValue < currentResult.score?.integerValue
                {
                    result = currentResult
                }
            }
            else
            {
                result = currentResult
            }
        }
        return result
    }
    
    func getEntity(className: String, withKey key: String, andValue value: String) -> NSManagedObject?
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let assetEntity = NSEntityDescription.entityForName(className, inManagedObjectContext: appDelegate.managedObjectContext)
        
        let fetch = NSFetchRequest()
        fetch.entity = assetEntity
        
        let predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])
        fetch.predicate = predicate
        
        var fetchedResults: [AnyObject]?
        
        do
        {
            try fetchedResults = appDelegate.managedObjectContext.executeFetchRequest(fetch) as! [NSManagedObject]
        }
        catch
        {
            NSLog("Error fetching entity \(className) with key \(key) and value \(value)")
        }
        
        if let results = fetchedResults
        {
            return results[0] as? NSManagedObject
        }
        
        return nil
    }
    
    func getChord(name: String) -> Chord
    {
        return self.getEntity("Chord", withKey: "name", andValue: name) as! Chord
    }
    
    func getAllChords() -> [Chord]?
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let assetEntity = NSEntityDescription.entityForName("Chord", inManagedObjectContext: appDelegate.managedObjectContext)
        
        let fetch = NSFetchRequest()
        fetch.entity = assetEntity
        
        let predicate = NSPredicate(format: "name != %@", argumentArray: ["--"])
        fetch.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "sortNumber", ascending: true)
        fetch.sortDescriptors = [sortDescriptor]

        
        var fetchedResults: [AnyObject]?
        
        do
        {
            try fetchedResults = appDelegate.managedObjectContext.executeFetchRequest(fetch) as! [NSManagedObject]
        }
        catch
        {
            NSLog("Error fetching entity all chords: \(error)")
        }

        return fetchedResults as? [Chord]
    }
    
    func getAllResults() -> [Result]?
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let assetEntity = NSEntityDescription.entityForName("Result", inManagedObjectContext: appDelegate.managedObjectContext)
        
        let fetch = NSFetchRequest()
        fetch.entity = assetEntity
        
        let sortDescriptor = NSSortDescriptor(key: "score", ascending: true)
        fetch.sortDescriptors = [sortDescriptor]
        
        var fetchedResults: [AnyObject]?
        
        do
        {
            try fetchedResults = appDelegate.managedObjectContext.executeFetchRequest(fetch) as! [NSManagedObject]
        }
        catch
        {
            NSLog("Error fetching entity all chords: \(error)")
        }
        
        return fetchedResults as? [Result]
    }

    
    func addResult(chord1: Chord, chord2: Chord, score: Int)
    {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let result = NSEntityDescription.insertNewObjectForEntityForName("Result", inManagedObjectContext: context) as! Result
        result.addChord(chord1, chord2: chord2)
        result.score = NSNumber(integer: score)
        
        do
        {
            try context.save()
        }
        catch
        {
            NSLog("Error adding result")
        }
        
    }
    
    func initData()
    {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let chord1 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord1.name = "D"
        chord1.sortNumber = 0
        
        let chord2 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord2.name = "A"
        chord2.sortNumber = 1
        
        let chord3 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord3.name = "E"
        chord3.sortNumber = 2
        
        let chord4 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord4.name = "Amin"
        chord4.sortNumber = 3
        
        let chord5 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord5.name = "Emin"
        chord5.sortNumber = 4
        
        let chord6 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord6.name = "Dmin"
        chord6.sortNumber = 5
        
        let chord7 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord7.name = "G"
        chord7.sortNumber = 6
        
        let chord8 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord8.name = "C"
        chord8.sortNumber = 7
        
        let chord9 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord9.name = "G7"
        chord9.sortNumber = 8
        
        let chord10 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord10.name = "C7"
        chord10.sortNumber = 9
        
        let chord11 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord11.name = "B7"
        chord11.sortNumber = 10
        
        let chord12 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord12.name = "Fmaj7"
        chord12.sortNumber = 11
        
        let chord13 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord13.name = "A7"
        chord13.sortNumber = 12
        
        let chord14 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord14.name = "D7"
        chord14.sortNumber = 13
        
        let chord15 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord15.name = "E7"
        chord15.sortNumber = 14
        
        let chord16 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord16.name = "F"
        chord16.sortNumber = 15

        let chord17 = NSEntityDescription.insertNewObjectForEntityForName("Chord", inManagedObjectContext: context) as! Chord
        chord17.name = "--"
        chord17.sortNumber = 999

        do
        {
            try context.save()
        }
        catch
        {
            NSLog("Error saving in initialization")
        }
        
        
    }
}