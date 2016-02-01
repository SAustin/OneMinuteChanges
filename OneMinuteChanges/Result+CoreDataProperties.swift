//
//  Result+CoreDataProperties.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/30/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Result {

    @NSManaged var date: NSDate?
    @NSManaged var score: NSNumber?
    @NSManaged var chords: NSSet?

}
