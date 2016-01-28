//
//  ViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/23/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController, TimerLabelDelegate, ChordSelectionDelegate
{
    @IBOutlet var timerLabel: UILabel?
    @IBOutlet var timerButton: UIButton?
    var timer: TimerLabel?
    
    var sequenceType: ChordSequenceType?
    var chordSequence: [(Chord, Chord)]?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.timer = TimerLabel(label: self.timerLabel, timerType: .Timer)
        self.timer?.timerDelegate = self
        self.timer?.setCountDownTime(60)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startWasPressed(sender: UIButton)
    {
        if self.timer!.counting
        {
            self.timer?.pause()
            self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)

        }
        else
        {
            self.timer?.start()
            self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)
        }
    }
    
    //MARK: - Chord Selection Delegate
    func randomChordsWereSelected(chordList: [Chord])
    {
        var fullList = [(Chord, Chord)]()
        //Create the full list of chords
        for i in 0...chordList.count - 1
        {
            for j in i+1...chordList.count - 1
            {
                fullList.append((chordList[i], chordList[j]))
            }
        }
        
        fullList.shuffleInPlace()
        
        self.chordSequence = fullList
    }
    
    func chordSequenceWasSelected(chordSequence: [(Chord, Chord)])
    {
        self.chordSequence = chordSequence.shuffle()
    }
    
    func singleChordWasSelected(chord: Chord)
    {
        var fullList = [(Chord, Chord)]()
        
        for i in 0...Chord.Count.rawValue
        {
            if chord != Chord(rawValue: i)
            {
                fullList.append((chord, Chord(rawValue: i)!))
            }
        }
        
        self.chordSequence = fullList.shuffle()
    }
    
    
    //MARK: - Timer Delegate

    func timerLabel(timerLabel: TimerLabel, countingTo time: NSTimeInterval, timerType: TimerLabelType)
    {
        
    }
    
    func timerLabel(timerLabel: TimerLabel, customTextToDisplayAtTime time: NSTimeInterval) -> String?
    {
        return nil
    }
    
    func timerLabel(timerLabel: TimerLabel, finishedCountDownTimerWithTime countTime: NSTimeInterval)
    {
        self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
    }
}

