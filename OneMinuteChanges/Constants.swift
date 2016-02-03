//
//  Constants.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/27/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

let kCountdownTime: NSTimeInterval = 60
let kPrepareTime = 3
let kCurrentChordSequence = "OneMinuteChangesCurrentChordSequence"

/*
* Delay
* Runs x code after a delay
*/

func delay(delay:Double, closure:()->())
{
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

/*
* Performs a countdown.
* Method performs countdownClosure at each second, and finalClosure when the countdown is finished.
*/
func countdown(seconds: Int,
    eachSecondAction countdownClosure: (timeIndex: Int) -> (),
    finalAction finalClosure: () -> ())
{
    for index in 1...(seconds - 1)
    {
        delay(Double(index))
            {
                countdownClosure(timeIndex: index)
        }
    }
    delay(Double(seconds))
        {
            finalClosure()
    }
}

enum Recommendation: Int
{
    case ProblemChords = 0
    case BeginnerOne
    case BeginnerTwo
    case BeginnerThree
    case BeginnerFour
    case BeginnerFive
    case BeginnerSix
    case BeginnerSeven
    case BeginnerEight
    case BeginnerNine
    case Count
    
    func description() -> String
    {
        switch self
        {
        case .ProblemChords:
            return "Problem Chords"
        case .BeginnerOne:
            return "Beginner Week One"
        case .BeginnerTwo:
            return "Beginner Week Two"
        case .BeginnerThree:
            return "Beginner Week Three"
        case .BeginnerFour:
            return "Beginner Week Four"
        case .BeginnerFive:
            return "Beginner Week Five"
        case .BeginnerSix:
            return "Beginner Week Six"
        case .BeginnerSeven:
            return "Beginner Week Seven"
        case .BeginnerEight:
            return "Beginner Week Eight"
        case .BeginnerNine:
            return "Beginner Week Nine"
        default:
            return ""
            
        }
    }
    
    func getSequence() -> [(Chord, Chord)]?
    {
        let dataHelper = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper

        switch self
        {
        case .ProblemChords:
            return (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.selectProblemChordCombos()
        case .BeginnerOne:
            return [(dataHelper.getChord("D"), dataHelper.getChord("A")), (dataHelper.getChord("D"), dataHelper.getChord("E")), (dataHelper.getChord("A"), dataHelper.getChord("E"))]
        case .BeginnerTwo:
            return [(dataHelper.getChord("Amin"), dataHelper.getChord("E")),
                (dataHelper.getChord("Amin"), dataHelper.getChord("Dmin")),
                (dataHelper.getChord("A"), dataHelper.getChord("Dmin")),
                (dataHelper.getChord("E"), dataHelper.getChord("D")),
                (dataHelper.getChord("Emin"), dataHelper.getChord("D"))]
        case .BeginnerThree:
            return [(dataHelper.getChord("C"), dataHelper.getChord("Amin")),
                (dataHelper.getChord("C"), dataHelper.getChord("A")),
                (dataHelper.getChord("C"), dataHelper.getChord("G")),
                (dataHelper.getChord("G"), dataHelper.getChord("E")),
                (dataHelper.getChord("G"), dataHelper.getChord("D"))]
        case .BeginnerFour:
            return [(dataHelper.getChord("C"), dataHelper.getChord("G7")),
                (dataHelper.getChord("C7"), dataHelper.getChord("Fmaj7")),
                (dataHelper.getChord("E"), dataHelper.getChord("B7")),
                (dataHelper.getChord("C7"), dataHelper.getChord("G7")),
                (dataHelper.getChord("D"), dataHelper.getChord("A")),
                (dataHelper.getChord("D"), dataHelper.getChord("A")),
                (dataHelper.getChord("E7"), dataHelper.getChord("A")),
                (dataHelper.getChord("Fmaj7"), dataHelper.getChord("A"))]
        case .BeginnerFive:
            return nil
        case .BeginnerSix:
            return [(dataHelper.getChord("F"), dataHelper.getChord("C")),
                (dataHelper.getChord("F"), dataHelper.getChord("E")),
                (dataHelper.getChord("F"), dataHelper.getChord("D")),
                (dataHelper.getChord("F"), dataHelper.getChord("Amin")),
                (dataHelper.getChord("F"), dataHelper.getChord("G"))]
        case .BeginnerSeven:
            return nil
        case .BeginnerEight:
            return nil
        case .BeginnerNine:
            return nil
        case .Count:
            return nil
        }
    }
}

func getScoreColor(score: Int) -> UIColor
{
    switch score
    {
    case 0...29:
        return UIColor.redColor()
    case 30...49:
        return UIColor.orangeColor()
    default:
        return UIColor.greenColor()
        
    }
}

