//
//  Result.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/30/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import CoreData


class Result: NSManagedObject
{    
// Insert code here to add functionality to your managed object subclass
    func addChord(chord1: Chord, chord2: Chord)
    {
        self.chords = NSSet(array: [chord1, chord2])
        chord1.addResult(self)
        chord2.addResult(self)
    }
}
