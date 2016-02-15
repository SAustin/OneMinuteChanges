//
//  CustomCells.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 1/27/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

class RandomChordCell: UITableViewCell
{
    @IBOutlet var chordNameLabel: UILabel?
}

class SpecificPairCell: UITableViewCell
{
    @IBOutlet var firstChord: UIButton?
    @IBOutlet var secondChord: UIButton?
}

class ChordDictionaryCell: UITableViewCell
{
    @IBOutlet var chordName: UILabel?
    @IBOutlet var chordTab: UIImageView?
}

class TopScoreListCell: UITableViewCell
{
    @IBOutlet var chordName: UILabel?
}

class ResultListCell: UITableViewCell
{
    @IBOutlet var firstChordLabel: UILabel?
    @IBOutlet var secondChordLabel: UILabel?
    @IBOutlet var scoreLabel: UILabel?
}

class SettingsTrueFalseCell: UITableViewCell
{
    @IBOutlet var settingText: UILabel?
    @IBOutlet var settingValue: UISwitch?
}

class SettingsActionCell: UITableViewCell
{
    @IBOutlet var settingText: UILabel?
    @IBOutlet var additionalInfoText: UILabel?
}

class SettingsNumericCell: UITableViewCell
{
    @IBOutlet var settingText: UILabel?
    @IBOutlet var settingValue: UITextField?
}
