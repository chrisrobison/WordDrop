//
//  StartMenuViewController.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 6/9/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import UIKit

class StartMenuViewController: UIViewController {

    @IBAction func startButton(sender: UIButton) {
    }
    
    @IBAction func optionsButton(sender: UIButton) {
    }
    
    @IBAction func helpButton(sender: UIButton) {
    }
    
    @IBAction func aboutButton(sender: UIButton) {
    }
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startBtn.layer.cornerRadius = 10
        startBtn.layer.borderWidth = 1
        startBtn.layer.borderColor = UIColor.clearColor().CGColor
        
        optionsBtn.layer.cornerRadius = 10
        optionsBtn.layer.borderWidth = 1
        optionsBtn.layer.borderColor = UIColor.clearColor().CGColor

        helpBtn.layer.cornerRadius = 10
        helpBtn.layer.borderWidth = 1
        helpBtn.layer.borderColor = UIColor.clearColor().CGColor

        aboutBtn.layer.cornerRadius = 10
        aboutBtn.layer.borderWidth = 1
        aboutBtn.layer.borderColor = UIColor.clearColor().CGColor
        
        adjustFontsForScreenSize()
        
        // Do any additional setup after loading the view.
    }
    
    func adjustFontsForScreenSize() {
        var fontAdjustment = 0
        var screenSize = UIScreen.mainScreen().bounds.size
        core.data.screenSize = Double(screenSize.width)
        
        if screenSize.height == 480 {
            core.data.screenSize = 480
            // iPhone 4
            fontAdjustment = -2
        } else if screenSize.height == 568 {
            core.data.screenSize = 568
            // IPhone 5
            fontAdjustment = -4
        } else if screenSize.width == 375 {
            // iPhone 6
            fontAdjustment = 0
        } else if screenSize.width == 414 {
            // iPhone 6+
            fontAdjustment = 3
        } else if screenSize.width == 768 {
            // iPad
            fontAdjustment = 6
        }
        
        for lab in [self.startBtn, self.optionsBtn, self.helpBtn, self.aboutBtn] {
            var f = lab.titleLabel?.font
            lab.titleLabel?.font = f!.fontWithSize(f!.pointSize + CGFloat(fontAdjustment))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
