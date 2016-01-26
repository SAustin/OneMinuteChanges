//
//  ViewController.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/23/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController
{
    @IBOutlet var timerLabel: TimerLabel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.timerLabel = TimerLabel(timerType: .Timer)
        self.timerLabel?.setCountDownTime(60)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

