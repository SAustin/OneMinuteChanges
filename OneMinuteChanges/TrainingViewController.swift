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
    @IBOutlet var currentChordPairLabel: UILabel?
    @IBOutlet var nextChordPairLabel: UILabel?
    @IBOutlet var numberOfAttemptsLabel: UILabel?
    @IBOutlet var previousMaximum: UILabel?
    @IBOutlet var currentAttemptTextField: UITextField?
    @IBOutlet var skipButton: UIButton?
    @IBOutlet var timerButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    var timer: TimerLabel?
    var timerEnded = false
    
    var currentChord = 0
    var chordSequence: [(Chord, Chord)]?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.timer = TimerLabel(label: self.timerLabel, timerType: .Timer)
        self.timer?.timeFormat = "mm:ss"
        self.timer?.timerDelegate = self
        self.timer?.setCountDownTime(kCountdownTime)
        
        self.resetButton?.hidden = true
        
        if let _ = self.chordSequence
        {
            self.updateChordLabels()
        }
        else
        {
            self.currentChordPairLabel?.text = "--"
            self.nextChordPairLabel?.text = "--"
        }
        
        self.previousMaximum?.text = "--"
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startWasPressed(sender: UIButton)
    {
        if self.chordSequence == nil ||
           self.chordSequence?.count == 0
        {
            let alertController = UIAlertController(title: "Warning", message: "You must select chords to practice before you begin.", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default)
                {
                    alertAction in
                    //Doing nothing here, for the moment.
                })
            
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        else if self.timer!.counting
        {
            self.timer?.pause()
            self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
        }
        else
        {
            self.timer?.start()
            self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)
            self.resetButton?.hidden = false
        }
    }
    
    @IBAction func viewTapped(sender: AnyObject)
    {
        self.currentAttemptTextField?.resignFirstResponder()
    }
    
    @IBAction func resetWasPresed(sender: UIButton)
    {
        self.timer?.reset()
        self.timer!.setCountDownTime(kCountdownTime)
    }
    
    @IBAction func skipWasPressed(sender: UIButton)
    {
        if self.currentAttemptTextField?.text == "" && self.timerEnded
        {
            let alertController = UIAlertController(title: "Warning", message: "You did not enter a new score.", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Fix it!", style: .Cancel)
                {
                    alertAction in
                    //Doing nothing here, for the moment.
                })
            alertController.addAction(UIAlertAction(title: "That's fine", style: .Default)
                {
                    alertAction in
                    self.skipNextLogic()
                })

            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        else
        {
            self.skipNextLogic()
        }
    }
    
    func skipNextLogic()
    {
        //We've finished a minute; this is "next" not "skip"
        if self.timerEnded
        {
            let (chord1, chord2) = (self.chordSequence?[self.currentChord])!
            (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.addResult(chord1, chord2: chord2, score: (((self.currentAttemptTextField?.text)! as NSString).integerValue))
            self.timerEnded = false
        }
        else if self.timer!.counting
        {
            self.startWasPressed(self.timerButton!)
        }
        self.timer!.reset()
        self.timer!.setCountDownTime(kCountdownTime)
        self.nextChord()
        
    }
    
    func nextChord()
    {
        //TODO: Update 'next' button to skip, if necessary
        if self.timerEnded
        {
            let skipPath = NSBundle.mainBundle().pathForResource("skipButton", ofType: "png")
            self.skipButton?.setBackgroundImage(UIImage(contentsOfFile: skipPath!)!, forState: .Normal)
        }
        if ++self.currentChord == self.chordSequence?.count
        {
            self.currentChord = 0
        }
        
        self.updateChordLabels()
    }
    
    func updateChordLabels()
    {
        var (chord1, chord2) = (self.chordSequence?[self.currentChord])!
        self.currentChordPairLabel?.text = "\(chord1.name!) - \(chord2.name!)"
        
        var nextChord = self.currentChord + 1
        if nextChord == self.chordSequence?.count
        {
            nextChord = 0
        }
        (chord1, chord2) = (self.chordSequence?[nextChord])!
        self.nextChordPairLabel?.text = "\(chord1.name!) - \(chord2.name!)"
        
        self.currentAttemptTextField?.text = ""
        
        let bestResult = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.getBestResultFor(chord1, chord2: chord2)
        var labelColor: UIColor
        if let result = bestResult
        {
            switch result.score!.integerValue
            {
            case 0...29:
                labelColor = UIColor.redColor()
            case 30...49:
                labelColor = UIColor.yellowColor()
            default:
                labelColor = UIColor.greenColor()
            }
            self.previousMaximum?.text = "\(result.score!)"
        }
        else
        {
            labelColor = UIColor.blackColor()
            self.previousMaximum?.text = "--"
        }
        self.previousMaximum?.textColor = labelColor
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        switch segue.identifier!
        {
        case "chordSelectionSegue":
            let controller = segue.destinationViewController as! ChordSelectionViewController
            controller.chordSelectionDelegate = self
        default:
            NSLog("Weird segue from training controller")
        }
    }
    
    //MARK: - Chord Selection Delegate
    func randomChordsWereSelected(chordList: [Chord])
    {
        var fullList = [(Chord, Chord)]()
        //Create the full list of chords
        for i in 0...chordList.count - 1
        {
            var j = i+1
            while j < chordList.count
            {
                fullList.append((chordList[i], chordList[j]))
                j++
            }
        }
        
        fullList.shuffleInPlace()
        
        self.chordSequence = fullList
        self.currentChord = 0
        self.updateChordLabels()
    }
    
    func chordSequenceWasSelected(chordSequence: [(Chord, Chord)])
    {
        self.chordSequence = chordSequence.shuffle()
        self.currentChord = 0
        self.updateChordLabels()
    }
    
    func singleChordWasSelected(chord: Chord)
    {
        var fullList = [(Chord, Chord)]()
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        for i in 0...(appDelegate.chordList?.count)! - 1
        {
            if chord != appDelegate.chordList?[i]
            {
                fullList.append((chord, (appDelegate.chordList?[i])!))
            }
        }
        
        self.chordSequence = fullList.shuffle()
        self.currentChord = 0
        self.updateChordLabels()
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
        //TODO: Change 'skip' to 'next'
        let nextPath = NSBundle.mainBundle().pathForResource("nextButton", ofType: "png")
        self.skipButton?.setBackgroundImage(UIImage(contentsOfFile: nextPath!)!, forState: .Normal)

        self.resetButton?.hidden = true
        self.timerEnded = true
        self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
    }
}

