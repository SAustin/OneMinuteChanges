//
//  Constants.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/27/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation

let kCountdownTime: NSTimeInterval = 60

enum ChordSequenceType: Int
{
    case Random = 0
    case Schedule
    case Targeted
}

enum Chord: Int
{
    case D = 0
    case A
    case E
    case Amin
    case Emin
    case Dmin
    case G
    case C
    case G7
    case C7
    case B7
    case Fmaj7
    case A7
    case D7
    case E7
    case F
    case Count
    
    func description() -> String
    {
        switch self
        {
        case .D:
            return "D"
        case .A:
            return "A"
        case .E:
            return "E"
        case .Amin:
            return "Amin"
        case .Emin:
            return "Emin"
        case .Dmin:
            return "Dmin"
        case .G:
            return "G"
        case .C:
            return "C"
        case .G7:
            return "G7"
        case .C7:
            return "C7"
        case .B7:
            return "B7"
        case .Fmaj7:
            return "Fmaj7"
        case .A7:
            return "A7"
        case .D7:
            return "D7"
        case .E7:
            return "E7"
        case .F:
            return "F"
        default:
            return "Count"
        }
    }
}

func delay(delay:Double, closure:()->())
{
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}