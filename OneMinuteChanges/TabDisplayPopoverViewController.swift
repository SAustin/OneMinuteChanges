//
//  TabDisplayPopoverViewController.swift
//  OneMinuteChanges
//
//  Created by Brittany Austin on 2/2/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

class TabDisplayPopoverViewController: UIViewController
{
    @IBOutlet var tabImage: UIImageView?
    var chordToDisplay: Chord?
    
    override func viewDidLoad()
    {
        let imagePath = NSBundle.mainBundle().pathForResource(chordToDisplay?.fileName, ofType: "png")
        
        if let path = imagePath
        {
            self.tabImage?.image = UIImage(contentsOfFile: path)
        }
    }

    override func shouldAutorotate() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAllowRotation)
    }

}