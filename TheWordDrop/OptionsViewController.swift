//
//  OptionsMenuViewController.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 6/9/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import UIKit
protocol OptionsMenuViewControllerDelegate {
    func optionsDidChange(vc: OptionsMenuViewController, command: (String, String))
}

class OptionsMenuViewController: UIViewController {
    var thisDelegate: OptionsMenuViewControllerDelegate?
    
    @IBOutlet weak var bgmusic: UISwitch!
    @IBOutlet weak var speak: UISwitch!
    @IBOutlet weak var soundeffects: UISwitch!
    @IBOutlet weak var skill: UISegmentedControl!
    
    @IBAction func bgmusicAction(sender: UISwitch) {
        core.data.prefs["bgmusic"] = sender.on
        saveSwitchesStates()
        
        if (core.data.musicPlayer != nil) {
            if (sender.on) {
                if (!core.data.musicPlayer!.playing) {
                    core.data.musicPlayer!.play()
                }
            } else {
                if (core.data.musicPlayer!.playing) {
                    core.data.musicPlayer!.stop()
                }
            }
        }
    }
    
    @IBAction func speakAction(sender: UISwitch) {
        core.data.prefs["speak"] = sender.on
        saveSwitchesStates()
    }
    
    @IBAction func soundeffectsAction(sender: UISwitch) {
        core.data.prefs["soundeffects"] = sender.on
        saveSwitchesStates()
    }
    
    @IBAction func skillAction(sender: UISegmentedControl) {
        core.data.prefs["skill"] = sender.selectedSegmentIndex
        saveSwitchesStates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restoreSwitchesStates();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveSwitchesStates", name: "kSaveSwitchesStatesNotification", object: nil)
    }
    
    func saveSwitchesStates() {
        NSUserDefaults.standardUserDefaults().setBool(bgmusic!.on, forKey: "bgmusic")
        NSUserDefaults.standardUserDefaults().setBool(speak!.on, forKey: "speak")
        NSUserDefaults.standardUserDefaults().setBool(soundeffects!.on, forKey: "soundeffects")
        NSUserDefaults.standardUserDefaults().setInteger(skill!.selectedSegmentIndex, forKey: "skill")
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func restoreSwitchesStates() {
        var firstRun : Bool? = !NSUserDefaults.standardUserDefaults().boolForKey("firstrun")
        //println("firstRun: \(firstRun)")
        var bgmusicState : Bool? = NSUserDefaults.standardUserDefaults().boolForKey("bgmusic")
        if firstRun! || bgmusicState == nil {
            bgmusicState = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "bgmusic")
            core.data.prefs["bgmusic"] = true
        }
        //println("bgmusic: \(bgmusicState)")
        bgmusic!.on = bgmusicState!
        
        var speakState : Bool? = NSUserDefaults.standardUserDefaults().boolForKey("speak")
        if firstRun! || speakState == nil {
            speakState = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "speak")
            core.data.prefs["speak"] = true
        }
        //println("speak: \(speakState)")
        
        speak!.on = speakState!
        
        var effectsState : Bool? = NSUserDefaults.standardUserDefaults().boolForKey("soundeffects")
        if firstRun! || effectsState == nil {
            effectsState = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "soundeffects")
            core.data.prefs["soundeffects"] = true
        }
        //println("soundeffects: \(effectsState)")
        soundeffects!.on = effectsState!
        
        var skillState : Int? = NSUserDefaults.standardUserDefaults().integerForKey("skill")
        if firstRun! || skillState == nil {
            skillState = 1
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "skill")
            core.data.prefs["skill"] = 1
        }
        //println("skill: \(skillState)")
        skill!.selectedSegmentIndex = skillState!
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstrun")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
