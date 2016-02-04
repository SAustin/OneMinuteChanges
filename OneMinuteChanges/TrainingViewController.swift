//
//  ViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/23/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import UIKit
import AVFoundation

class TrainingViewController: UIViewController, TimerLabelDelegate, ChordSelectionDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet var timerLabel: UILabel?
    @IBOutlet var currentChordOneButton: UIButton?
    @IBOutlet var currentChordTwoButton: UIButton?
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
    
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.timer = TimerLabel(label: self.timerLabel, timerType: .Timer)
        self.timer?.timeFormat = "mm:ss"
        self.timer?.timerDelegate = self
        self.timer?.setCountDownTime(kCountdownTime)
        
        self.resetButton?.hidden = true
        
        if let savedSequence = NSUserDefaults.standardUserDefaults().objectForKey(kCurrentChordSequence)
        {
            self.chordSequence = self.convertArrayToSequence(savedSequence as! [String])
            self.chordSequence?.shuffleInPlace()
        }

        if let _ = self.chordSequence
        {
            self.updateChordLabels()
        }
        else
        {
            self.currentChordOneButton?.setTitle("--", forState: .Normal)
            self.currentChordTwoButton?.setTitle("--", forState: .Normal)
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
            let soundPath = NSBundle.mainBundle().pathForResource("beep-07", ofType: "wav")
            
            try! self.soundPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: soundPath!))
            
            self.soundPlayer!.prepareToPlay()
            
            let prepareAlertController = UIAlertController(title: "Countdown", message: "Preparing to start!", preferredStyle: .Alert)
            self.presentViewController(prepareAlertController, animated: true, completion: nil)
            
            countdown(kPrepareTime, eachSecondAction:
                {
                    timeIndex in
                    
                    let startTime = kPrepareTime - timeIndex
                    
                    prepareAlertController.message = "Timer starting in \(startTime)!"
                    
                    self.playBeeps(1)
                },
                finalAction:
                {
                    prepareAlertController.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.playBeeps(2)
                    self.timer?.start()
                    self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)
                    self.resetButton?.hidden = false
            })
            
        }
            
        
    }
    
    func playBeeps(numberOfBeeps: Int)
    {
        for index in 0...numberOfBeeps - 1
        {
            delay(Double(index)*0.2)
            {
                self.soundPlayer?.play()
                return
            }
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
    
    @IBAction func chordNameWasPresed(sender: UIButton)
    {
        let popover = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabDisplayPopoverViewController") as! TabDisplayPopoverViewController
        popover.modalPresentationStyle = .Popover
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.sourceView = sender
        popover.popoverPresentationController?.sourceRect = sender.frame
        popover.popoverPresentationController?.permittedArrowDirections = .Any
        popover.preferredContentSize = CGSizeMake(400, 600)
        
        popover.chordToDisplay = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.getChord(sender.titleLabel!.text!)
        
        self.presentViewController(popover, animated: true, completion: nil)

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
        self.currentChordOneButton?.setTitle(chord1.name!, forState: .Normal)
        self.currentChordTwoButton?.setTitle(chord2.name!, forState: .Normal)
        
        var nextChord = self.currentChord + 1
        if nextChord == self.chordSequence?.count
        {
            nextChord = 0
        }
        
        self.currentAttemptTextField?.text = ""
        
        let bestResult = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.getBestResultFor(chord1, chord2: chord2)

        (chord1, chord2) = (self.chordSequence?[nextChord])!
        self.nextChordPairLabel?.text = "\(chord1.name!) - \(chord2.name!)"

        var labelColor: UIColor
        if let result = bestResult
        {
            labelColor = getScoreColor(result.score!.integerValue)

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
    
    // MARK: - PopoverControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
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
        
        self.chordSequence = fullList.shuffle()
        self.currentChord = 0
        self.updateChordLabels()
        
        NSUserDefaults.standardUserDefaults().setObject(self.convertSequenceToArray(), forKey: kCurrentChordSequence)
    }
    
    func chordSequenceWasSelected(chordSequence: [(Chord, Chord)])
    {
        if chordSequence.count == 0
        {
            let dataHelper = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper
            self.chordSequence = [(dataHelper.getChord("--"), dataHelper.getChord("--"))]
        }
        else
        {
            self.chordSequence = chordSequence.shuffle()
        }
        
        self.currentChord = 0
        self.updateChordLabels()
        
        NSUserDefaults.standardUserDefaults().setObject(self.convertSequenceToArray(), forKey: kCurrentChordSequence)
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
        
        NSUserDefaults.standardUserDefaults().setObject(self.convertSequenceToArray(), forKey: kCurrentChordSequence)
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
        self.playBeeps(3)
        
        let nextPath = NSBundle.mainBundle().pathForResource("nextButton", ofType: "png")
        self.skipButton?.setBackgroundImage(UIImage(contentsOfFile: nextPath!)!, forState: .Normal)

        self.resetButton?.hidden = true
        self.timerEnded = true
        self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
    }
    
    func convertSequenceToArray() -> [String]?
    {
        if let sequence = self.chordSequence
        {
            var returnArray = [String]()
            for (chord1, chord2) in sequence
            {
                returnArray.append(chord1.name!)
                returnArray.append(chord2.name!)
            }
            return returnArray
        }
        else
        {
            return nil
        }
    }
    
    func convertArrayToSequence(source: [String]) -> [(Chord, Chord)]?
    {
        var returnSequence = [(Chord, Chord)]()
        var chord1: Chord
        var chord2: Chord
        
        let dataHelper = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper
        
        for index in 0...source.count - 1
        {
            if index % 2 == 0
            {
                chord1 = dataHelper.getChord(source[index])
                chord2 = dataHelper.getChord(source[index + 1])
                returnSequence.append((chord1, chord2))
            }
        }
        return returnSequence
    }
}

