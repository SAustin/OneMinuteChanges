//
//  ViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/23/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import UIKit
import AVFoundation

class TrainingViewController: UIViewController, TimerLabelDelegate, ChordSelectionDelegate, UIPopoverPresentationControllerDelegate, EZMicrophoneDelegate, EZAudioFFTDelegate
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
    var longerSequence: [(Chord, Chord)]?
    var chordCount: [Int]?
    
    var soundPlayer: AVAudioPlayer?
    
    @IBOutlet var audioPlot: EZAudioPlotGL?
    var microphone: EZMicrophone?
    var fft: EZAudioFFTRolling?
    var currentBuffer = [Float]()
    var previousIndex = 0
    var previousTime: NSDate?
    
    //Not sure I need this?
    var inputs: [AnyObject]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Set up audio session
        let session = AVAudioSession.sharedInstance()
        do
        {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        }
        catch
        {
            NSLog("\(error)")
        }
        
        //Background in app purchase stuff
        self.reload()
        
        //Set up audio plot look
        self.audioPlot?.backgroundColor = kLightBlueColor
        self.audioPlot?.color = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.audioPlot?.shouldMirror = true
        self.audioPlot?.shouldFill = true
        self.audioPlot?.plotType = .Rolling
        self.audioPlot?.gain = 0.8
        
        //Create microphone
        self.microphone = EZMicrophone(delegate: self)
        
        //Create FFT to keep track of incoming audio and calculate FFT
        self.fft = EZAudioFFTRolling(windowSize: kFFTViewControllerFFTWindowSize, sampleRate: Float(self.microphone!.audioStreamBasicDescription().mSampleRate), delegate: self)
        
        self.inputs = EZAudioDevice.inputDevices()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if let savedSequence = NSUserDefaults.standardUserDefaults().objectForKey(kCurrentChordSequence)
        {
            self.chordSequence = self.convertArrayToSequence(savedSequence as! [String])
            self.chordSequence?.shuffleInPlace()
            self.chordCount = Array<Int>(count: (self.chordSequence?.count)!, repeatedValue: 0)
        }
        
        self.setUpTimer()
        
        if let _ = self.chordSequence
        {
            self.updateChordLabels()
        }
        else
        {
            self.currentChordOneButton?.setTitle("--", forState: .Normal)
            self.currentChordTwoButton?.setTitle("--", forState: .Normal)
            self.previousMaximum?.textColor = getScoreColor(-1)
            self.previousMaximum?.text = "--"
            self.nextChordPairLabel?.text = "--"
        }
        
        self.currentAttemptTextField?.text = ""
        self.numberOfAttemptsLabel?.text = "0"
    }
    
    override func shouldAutorotate() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAllowRotation)
    }
    
    func reload()
    {
        globalProducts = []

        Products.store.requestProductsWithCompletionHandler
            {
                success, products in
                
                if success
                {
                    globalProducts = products
                }
                
        }
    }
    
    func setUpTimer()
    {
        self.timer = TimerLabel(label: self.timerLabel, timerType: .Timer)
        self.timer?.timeFormat = "mm:ss"
        self.timer?.timerDelegate = self
        self.timer?.setCountDownTime(NSTimeInterval(NSUserDefaults.standardUserDefaults().integerForKey(kSettingsTimerLength)*60))

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
            self.microphone?.stopFetchingAudio()
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
            
            currentAttemptTextField?.text = ""
            
            countdown(kPrepareTime, eachSecondAction:
                {
                    timeIndex in
                    
                    let startTime = kPrepareTime - timeIndex
                    
                    prepareAlertController.message = "Timer starting in \(startTime)!"
                    
                    self.playBeeps(1)
                },
                finalAction:
                {
                    self.playBeeps(2)
                    
                    prepareAlertController.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.chordCount?[self.currentChord] = (self.chordCount?[self.currentChord])! + 1
                    self.numberOfAttemptsLabel?.text = "\((self.chordCount?[self.currentChord])!)"

                    self.microphone?.startFetchingAudio()
                    self.timer?.start()
                    self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("pauseButton", ofType: "png")!), forState: .Normal)
            })
            
        }
        
        
    }
    
    func playBeeps(numberOfBeeps: Int)
    {
        for index in 0...numberOfBeeps - 1
        {
            delay(Double(index)*0.25)
                {
                    self.soundPlayer?.play()
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
        self.timer!.setCountDownTime(NSTimeInterval(NSUserDefaults.standardUserDefaults().integerForKey(kSettingsTimerLength)*60))
        currentAttemptTextField?.text = ""
        resetBuffer()
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
        if sender.titleLabel?.text != "--"
        {
            let popover = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabDisplayPopoverViewController") as! TabDisplayPopoverViewController
            popover.modalPresentationStyle = .Popover
            popover.popoverPresentationController?.delegate = self
            popover.popoverPresentationController?.sourceView = sender.titleLabel
            popover.popoverPresentationController?.sourceRect = sender.titleLabel!.frame
            popover.popoverPresentationController?.permittedArrowDirections = .Up
            let width = self.view.frame.size.width * 0.8
            popover.preferredContentSize = CGSizeMake(width, width*1.5)
            
            popover.chordToDisplay = (UIApplication.sharedApplication().delegate as! AppDelegate).dataHelper.getChord(sender.titleLabel!.text!)
            
            self.presentViewController(popover, animated: true, completion: nil)            
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
        self.timer!.setCountDownTime(NSTimeInterval(NSUserDefaults.standardUserDefaults().integerForKey(kSettingsTimerLength)*60))
        self.nextChord()
        
    }
    
    func nextChord()
    {
        let skipPath = NSBundle.mainBundle().pathForResource("skipButton", ofType: "png")
        skipButton?.setBackgroundImage(UIImage(contentsOfFile: skipPath!)!, forState: .Normal)
        
        currentChord = currentChord + 1
        if currentChord == chordSequence?.count
        {
            currentChord = 0
        }
        
        resetBuffer()
        
        updateChordLabels()
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
        case "settingsModalSegue":
            let controller = segue.destinationViewController as! SettingsViewController
            controller.settingsViewControllerDelegate = self
            
            if self.timer!.counting
            {
                self.startWasPressed(self.timerButton!)
            }
        default:
            NSLog("Weird segue from training controller")
        }
    }
    
    func countChordHits(fromPrevious: Bool) -> Int
    {
        var chordHitCount = 0
        if previousTime == nil
        {
            previousTime = NSDate().dateByAddingTimeInterval(0.2)
        }
        
        if currentBuffer.count > 0
        {
            var underMin = true
            
            let startIndex = fromPrevious ? previousIndex : 0
            
            for index in startIndex...currentBuffer.count - 1
            {
                if underMin && currentBuffer[index] > kMinimumSoundValue && fabs(previousTime!.timeIntervalSinceNow) > kMinimumTimeBetweenChords
                {
                    chordHitCount += 1
                    previousTime = NSDate()
                    underMin = false
                }
                else if !underMin && currentBuffer[index] < kMinimumSoundValue
                {
                    underMin = true
                }
            }
            previousIndex = currentBuffer.count
        }

        
        return chordHitCount
    }
    
    func resetBuffer()
    {
        currentBuffer = [Float]()
        previousTime = nil
        previousIndex = 0
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
    
    //MARK: - EZAudio delegate stuff
    func drawRollingPlot()
    {
        self.audioPlot?.plotType = .Rolling
        self.audioPlot?.shouldFill = true
        self.audioPlot?.shouldMirror = true
    }
    
    //
    // Note that any callback that provides streamed audio data (like streaming
    // microphone input) happens on a separate audio thread that should not be
    // blocked. When we feed audio data into any of the UI components we need to
    // explicity create a GCD block on the main thread to properly get the UI
    // to work.
    //
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>,
        withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32)
    {
        //
        // Getting audio data as an array of float buffer arrays. What does that mean?
        // Because the audio is coming in as a stereo signal the data is split into
        // a left and right channel. So buffer[0] corresponds to the float* data
        // for the left channel while buffer[1] corresponds to the float* data
        // for the right channel.
        //
        
        //
        // See the Thread Safety warning above, but in a nutshell these callbacks
        // happen on a separate audio thread. We wrap any UI updating in a GCD block
        // on the main thread to avoid blocking that audio flow.
        //
        
        //Calculate the FFT
        self.fft?.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
        
        //Update your own buffer
        currentBuffer.append(EZAudioUtilities.RMS(buffer[0], length: Int32(bufferSize)))
        
        dispatch_async(dispatch_get_main_queue())
            {
                self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioStreamBasicDescription audioStreamBasicDescription: AudioStreamBasicDescription)
    {
        EZAudioUtilities.printASBD(audioStreamBasicDescription)
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32)
    {
        //
        // Getting audio data as a buffer list that can be directly fed into the
        // EZRecorder or EZOutput. Say whattt...
        //
        
        
    }
    
    func microphone(microphone: EZMicrophone!, changedDevice device: EZAudioDevice!)
    {
        
    }
    
    //MARK: - EZAudioFFT Delegate
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length)
    {
        let maxFrequency = fft.maxFrequency
        let noteName = EZAudioUtilities.noteNameStringForFrequency(maxFrequency, includeOctave: true)
        
        //TODO: If noteName = chord1.max or chord2.max, or something, then
        if let _ = noteName
        {
            //self.currentAttemptTextField?.text = "\(((self.currentAttemptTextField?.text)! as NSString).integerValue + 1)"
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
                j += 1
            }
        }
        
        self.chordSequence = fullList.shuffle()
        self.chordCount = Array<Int>(count: (self.chordSequence?.count)!, repeatedValue: 0)
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
        
        self.chordCount = Array<Int>(count: (self.chordSequence?.count)!, repeatedValue: 0)
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
        self.chordCount = Array<Int>(count: (self.chordSequence?.count)!, repeatedValue: 0)
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
        self.microphone?.stopFetchingAudio()
        let nextPath = NSBundle.mainBundle().pathForResource("nextButton", ofType: "png")
        
        self.timerEnded = true
        resetBuffer()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAutomaticCounting)
        {
            currentAttemptTextField?.text =  "\((currentAttemptTextField!.text! as NSString).integerValue + countChordHits(true))"
        }
        
        delay(0.2)
            {
                self.timerButton?.setBackgroundImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("startButton", ofType: "png")!), forState: .Normal)
                self.skipButton?.setBackgroundImage(UIImage(contentsOfFile: nextPath!)!, forState: .Normal)
        }
        
        self.playBeeps(3)
    }
    
    func timerLabelDidUpdateLabel()
    {
        if timer!.counting && NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAutomaticCounting)
        {
            currentAttemptTextField?.text = "\((currentAttemptTextField!.text! as NSString).integerValue + countChordHits(true))"
        }
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

extension TrainingViewController: SettingsViewControllerDelegate
{
    func settingsWereUpdated(settingsWereUpdated: Bool)
    {
        if settingsWereUpdated
        {
            self.setUpTimer()
        }
    }
}

