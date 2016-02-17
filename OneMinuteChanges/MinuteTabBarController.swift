//
//  MinuteTabBarController.swift
//  OneMinuteChanges
//
//  Created by Brittany Austin on 2/16/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

class MinuteTabBarController: UITabBarController
{
    override func shouldAutorotate() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(kSettingsAllowRotation)
    }
}