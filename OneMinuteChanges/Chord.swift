//
//  Chord.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/30/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import CoreData


class Chord: NSManagedObject
{

// Insert code here to add functionality to your managed object subclass

    func addResult(result: Result)
    {
        if let oldResults = self.results
        {
            let newResults = NSMutableSet(set: oldResults)
            newResults.addObject(result)
            self.results = newResults
        }
        else
        {
            self.results = NSSet(array: [result])
        }
    }
}
