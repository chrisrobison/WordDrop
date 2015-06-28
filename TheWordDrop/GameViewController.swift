//
//  GameViewController.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 4/18/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

var on6plus : Bool {
    return UIScreen.mainScreen().traitCollection.displayScale > 2.5
}

class GameViewController: UIViewController, TheWordDropDelegate, UIGestureRecognizerDelegate, PauseSceneDelegate {
    var scene: GameScene!, theworddrop:TheWordDrop!, panPointReference:CGPoint?,
    gameScene: GameScene!, pausedScene: PauseScene!, pausedView: SKView!,
    startView: SKView?
    var overlayView: UIView!
    var alertView: UIView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!
    var bgmusicIV: UIImageView!, soundIV: UIImageView!, speakIV: UIImageView!, exitIV: UIImageView!

    var views = [String:SKView]()
    
    let transition = SKTransition.pushWithDirection(.Left, duration: NSTimeInterval(3.0))
    let bgmusicIcon = UIImage(named: "bgmusic")
    let nobgmusicIcon = UIImage(named: "no-bgmusic")
    let soundIcon = UIImage(named: "sound")
    let muteIcon = UIImage(named: "mute")
    let speakIcon = UIImage(named: "speak")
    let silentIcon = UIImage(named: "silent")
    let exitIcon = UIImage(named: "exit")
    
    var skView:SKView!, pauseView:SKView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreTitle: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelTitle: UILabel!
    @IBOutlet weak var tilesLabel: UILabel!
    @IBOutlet weak var tilesTitle: UILabel!
    @IBOutlet weak var lastWord: UILabel!
    @IBOutlet weak var infoPanel: UIView!
    @IBOutlet weak var wordPanel: UIView!
    @IBOutlet weak var scorePanel: UIView!
    @IBOutlet weak var wordsLabel: UILabel!
    @IBAction func settingsButton(sender: UIButton) {
        if (core.data.paused == true) {
            core.data.paused = false
            skView.scene?.paused = false
            gameScene.playBackgroundMusic()
            gameScene.startTicking()
            dismissAlert()
        } else {
            core.data.paused = true
            gameScene.stopBackgroundMusic()
            gameScene.stopTicking()
            showAlert()
            skView.scene?.paused = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        core.data.viewCache["words"] = wordPanel
        core.data.viewCache["score"] = scorePanel
        
        core.data.wordsLabel = wordsLabel
        core.data.scoreLabel = scoreLabel
        core.data.lastWord = lastWord
        
        animator = UIDynamicAnimator(referenceView: view)

        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        scene = gameScene
        
        gameScene.tick = didTick
        
        theworddrop = TheWordDrop()
        theworddrop.delegate = self
        theworddrop.beginGame()

        adjustFontsForScreenSize()

        createOverlay()
        createAlert()

        skView.presentScene(gameScene, transition: transition)
    }
    
    func createOverlay() {
        // Create a gray view and set its alpha to 0 so it isn't visible
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
    }
    
    func createAlert() {
        // Here the red alert view is created. It is created with rounded corners and given a shadow around it
        var alertWidth: CGFloat = core.data.screenWidth * 0.80
        var alertHeight: CGFloat = alertWidth * 0.90
        if (core.data.screenSize == 375) {
            alertHeight -= CGFloat(45)
        }
        if (core.data.screenSize == 414) {
            alertHeight -= CGFloat(45)
        }
        if core.data.screenSize == 768 {
            alertHeight = 240
            alertWidth = 300
        }
        
        let alertViewFrame: CGRect = CGRectMake(0, 0, alertWidth, alertHeight)
        //println("alertWidth: \(alertWidth) alertHeight: \(alertHeight) alertViewFrame: \(alertViewFrame) alertView: \(alertView)")
        alertView = UIView(frame: alertViewFrame)
        alertView.backgroundColor = UIColor.whiteColor()
        alertView.alpha = 0.0
        alertView.layer.cornerRadius = 10;
        alertView.layer.shadowColor = UIColor.blackColor().CGColor;
        alertView.layer.shadowOffset = CGSizeMake(0, 5);
        alertView.layer.shadowOpacity = 0.3;
        alertView.layer.shadowRadius = 10.0;
        
        // Create a button and set a listener on it for when it is tapped. Then the button is added to the alert view
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.setTitle("Back to Game", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.backgroundColor = UIColor(hue: 206.0/360.0, saturation: 0.66, brightness: 0.5, alpha: 1.0)
        button.frame = CGRectMake(0, 0, alertWidth, 40.0)
        
        button.addTarget(self, action: Selector("dismissAlert"), forControlEvents: UIControlEvents.TouchUpInside)
        
        alertView.addSubview(button)

        bgmusicIV = UIImageView(image: (core.data.prefs["bgmusic"] as! Bool) ? bgmusicIcon : nobgmusicIcon)
        bgmusicIV.frame = CGRectMake(20, 80, bgmusicIcon!.size.width, bgmusicIcon!.size.height)
        bgmusicIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "bgmusicTap:"))
        bgmusicIV.userInteractionEnabled = true
        var bgmusicLabel = UILabel()
        bgmusicLabel.text = "Music"
        bgmusicLabel.font = UIFont(name: "Helvetica Neue", size: 12.0)
        bgmusicLabel.frame = CGRectMake(-13, 50, 100, 20)
        bgmusicLabel.textAlignment = NSTextAlignment.Center
        bgmusicLabel.textColor = UIColor.blackColor()
        
        alertView.addSubview(bgmusicLabel)
        alertView.addSubview(bgmusicIV)
        
        soundIV = UIImageView(image: (core.data.prefs["soundeffects"] as! Bool) ? soundIcon : muteIcon)
        soundIV.frame = CGRectMake((alertWidth / 2) - (soundIcon!.size.width / 2), 80, soundIcon!.size.width, soundIcon!.size.height)
        soundIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "soundTap:"))
        soundIV.userInteractionEnabled = true
        
        var soundLabel = UILabel()
        soundLabel.text = "Sound"
        soundLabel.font = UIFont(name: "Helvetica Neue", size: 12.0)
        soundLabel.frame = CGRectMake((alertWidth / 2) - (soundIcon!.size.width / 2) - 35, 50, 100, 20)
        soundLabel.textAlignment = NSTextAlignment.Center
        soundLabel.textColor = UIColor.blackColor()
        
        alertView.addSubview(soundLabel)
        alertView.addSubview(soundIV)
        
        speakIV = UIImageView(image: (core.data.prefs["speak"] as! Bool) ? speakIcon : silentIcon)
        speakIV.frame = CGRectMake((alertWidth - 20) - (speakIcon!.size.width), 80, speakIcon!.size.width, speakIcon!.size.height)
        speakIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "speakTap:"))
        speakIV.userInteractionEnabled = true
        var speakLabel = UILabel()
        speakLabel.text = "Speak"
        speakLabel.font = UIFont(name: "Helvetica Neue", size: 12.0)
        speakLabel.frame = CGRectMake((alertWidth - 10) - (speakIcon!.size.width) - 50, 50, 100, 20)
        speakLabel.textAlignment = NSTextAlignment.Center
        speakLabel.textColor = UIColor.blackColor()
        
        alertView.addSubview(speakLabel)
        alertView.addSubview(speakIV)
        
        var helpLabel = UILabel()
        helpLabel.text = "Tap to toggle"
        helpLabel.frame = CGRectMake(0.0, 90 + speakIcon!.size.height, alertWidth, 20)
        helpLabel.textAlignment = NSTextAlignment.Center
        helpLabel.textColor = UIColor.lightGrayColor()
        helpLabel.font = UIFont(name: "Helvetica Neue", size: 14.0)
        alertView.addSubview(helpLabel)
        
        exitIV = UIImageView(image: exitIcon)
        exitIV.frame = CGRectMake((alertWidth / 2) - (exitIcon!.size.width / 2), 130 + speakIcon!.size.height, exitIcon!.size.width, exitIcon!.size.height)
        exitIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "exitTap:"))
        exitIV.userInteractionEnabled = true
        var exitLabel = UILabel()
        exitLabel.text = "Quit Game"
        exitLabel.font = UIFont(name: "Helvetica Neue", size: 12.0)
        exitLabel.frame = CGRectMake(0.0, (alertHeight - 30), alertWidth, 20)
        exitLabel.textAlignment = NSTextAlignment.Center
        exitLabel.textColor = UIColor.blackColor()
        alertView.addSubview(exitLabel)
        alertView.addSubview(exitIV)
        
        view.addSubview(alertView)
    }
    
    func bgmusicTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            //println("bgmusic icon tapped.")
            if (core.data.prefs["bgmusic"] as! Bool) {
                core.data.prefs["bgmusic"] = false
                bgmusicIV.image? = nobgmusicIcon!
                gameScene.stopBackgroundMusic()
            } else {
                core.data.prefs["bgmusic"] = true
                bgmusicIV.image? = bgmusicIcon!
                gameScene.playBackgroundMusic()
            }
            NSUserDefaults.standardUserDefaults().setBool(core.data.prefs["bgmusic"] as! Bool, forKey: "bgmusic")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func soundTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            //println("sound icon tapped.")
            if (core.data.prefs["soundeffects"] as! Bool) {
                core.data.prefs["soundeffects"] = false
                soundIV.image? = muteIcon!
            } else {
                core.data.prefs["soundeffects"] = true
                soundIV.image? = soundIcon!
            }
            NSUserDefaults.standardUserDefaults().setBool(core.data.prefs["soundeffects"] as! Bool, forKey: "soundeffects")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func speakTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            //println("speak icon tapped.")
            if (core.data.prefs["speak"] as! Bool) {
                core.data.prefs["speak"] = false
                speakIV.image? = silentIcon!
            } else {
                core.data.prefs["speak"] = true
                speakIV.image? = speakIcon!
            }
            NSUserDefaults.standardUserDefaults().setBool(core.data.prefs["speak"] as! Bool, forKey: "speak")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func exitTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            dismissAlert()
            core.data.paused = false
            skView.scene?.paused = false
            gameScene.stopTicking()
            gameScene.stopBackgroundMusic()
            self.performSegueWithIdentifier("gameoverSegue", sender: self)
            //println("speak icon tapped.")
            //self.gameDidEnd(theworddrop)
        }
    }
    
    func showAlert() {
        // When the alert view is dismissed, I destroy it, so I check for this condition here
        // since if the Show Alert button is tapped again after dismissing, alertView will be nil
        // and so should be created again
        if (alertView == nil) {
            createAlert()
        }
        
        // I create the pan gesture recognizer here and not in ViewDidLoad() to
        // prevent the user moving the alert view on the screen before it is shown.
        // Remember, on load, the alert view is created but invisible to user, so you
        // don't want the user moving it around when they swipe or drag on the screen.
        createGestureRecognizer()
        
        animator.removeAllBehaviors()
        
        // Animate in the overlay
        UIView.animateWithDuration(0.4) {
            self.overlayView.alpha = 0.5
        }
        
        // Animate the alert view using UIKit Dynamics.
        alertView.alpha = 1.0
        
        var snapBehaviour: UISnapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
        animator.addBehavior(snapBehaviour)
    }
    
    func dismissAlert() {
        
        animator.removeAllBehaviors()
        
        var gravityBehaviour: UIGravityBehavior = UIGravityBehavior(items: [alertView])
        gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0);
        animator.addBehavior(gravityBehaviour)
        
        // This behaviour is included so that the alert view tilts when it falls, otherwise it will go straight down
        var itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
        itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), forItem: alertView)
        animator.addBehavior(itemBehaviour)
        
        core.data.paused = false
        self.skView.scene?.paused = false
        self.gameScene.playBackgroundMusic()
        self.gameScene.startTicking()

        // Animate out the overlay, remove the alert view from its superview and set it to nil
        // If you don't set it to nil, it keeps falling off the screen and when Show Alert button is
        // tapped again, it will snap into view from below. It won't have the location settings we defined in createAlert()
        // And the more it 'falls' off the screen, the longer it takes to come back into view, so when the Show Alert button
        // is tapped again after a considerable time passes, the app seems unresponsive for a bit of time as the alert view
        // comes back up to the screen
        UIView.animateWithDuration(0.4, animations: {
            self.overlayView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.alertView.removeFromSuperview()
                self.alertView = nil
                
                
        })
        
    }
    
    func createGestureRecognizer() {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func pauseSceneDidFinish(myScene: PauseScene, command:String) {
        myScene.view?.removeFromSuperview()
        //println("pauseSceneDidFinish with command: \(command)")
    }
    
    func adjustFontsForScreenSize() {
        var fontAdjustment = 0
        var screenSize = UIScreen.mainScreen().bounds.size
        
        if screenSize.height == 480 {
            core.data.screenSize = 480
            //println("Detected iPhone 4/4s : screenSize=480")
            // iPhone 4
            fontAdjustment = -2
        } else if screenSize.height == 568 {
            core.data.screenSize = 568
            //println("Detected iPhone 5/5s : screenSize=568")
            // IPhone 5
            fontAdjustment = -1
        } else if screenSize.width == 375 {
            //println("Detected iPhone 6 : screenSize=375")
            core.data.screenSize = 375
            // iPhone 6
            fontAdjustment = 1
        } else if screenSize.width == 414 {
            //println("Detected iPhone 6+ : screenSize=414")
            core.data.screenSize = 414
            // iPhone 6+
            fontAdjustment = 3
        } else if screenSize.width == 768 {
            //println("Detected iPad : screenSize=768")
            core.data.screenSize = 768
            // iPad
            fontAdjustment = 10
            
            NumColumns = 11
            PreviewColumn = 11
            
        }
        
        for lab in [self.lastWord, self.scoreLabel, self.levelLabel, self.tilesLabel, self.scoreTitle, self.levelTitle, self.tilesTitle, self.wordsLabel] {
            let f = lab.font
            let s = lab.frame.size
            lab.font = f.fontWithSize(f.pointSize + CGFloat(fontAdjustment))
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTick() {
        theworddrop.letShapeFall()
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        theworddrop.dropShape()
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        if theworddrop != nil {
            theworddrop.rotateShape()
        }
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (core.data.BlockSize * 0.5) {
                // #4
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    theworddrop.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    theworddrop.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if (alertView != nil) {
            let panLocationInView = sender.locationInView(view)
            let panLocationInAlertView = sender.locationInView(alertView)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                
                let offset = UIOffsetMake(panLocationInAlertView.x - CGRectGetMidX(alertView.bounds), panLocationInAlertView.y - CGRectGetMidY(alertView.bounds));
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                
                animator.addBehavior(attachmentBehavior)
            }
            else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = panLocationInView
            }
            else if sender.state == UIGestureRecognizerState.Ended {
                animator.removeAllBehaviors()
                
                snapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
                
                if sender.translationInView(view).y > 100 {
                    dismissAlert()
                }
            }
        }
        
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #2
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func nextShape() {
        let newShapes = theworddrop.newShape()
        tilesLabel.text = "\(core.data.letterQueue.count)"
        if let fallingShape = newShapes.fallingShape {
            self.gameScene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.gameScene.movePreviewShape(fallingShape) {
                // #2
                self.view.userInteractionEnabled = true
                self.gameScene.startTicking()
            }
        }
    }
    
    func gameDidBegin(theworddrop: TheWordDrop) {
        theworddrop.level = 1
        core.data.level = 1
        theworddrop.score = 0
        
        core.data.initLetters(Int(theworddrop.level))
        
        levelLabel.text = "\(theworddrop.level)"
        scoreLabel.text = "\(theworddrop.score)"
        tilesLabel.text = "\(core.data.letterQueue.count)"
        lastWord.text = ""
        
        gameScene.animateLevelUp(Int(theworddrop.level))
        
        gameScene.tickLengthMillis = TickLengthLevelOne

        // The following is false when restarting a new game
        if theworddrop.nextShape != nil && theworddrop.nextShape!.blocks[0].sprite == nil {
            gameScene.addPreviewShapeToScene(theworddrop.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(theworddrop: TheWordDrop) {
        view.userInteractionEnabled = false
        gameScene.stopTicking()
        gameScene.stopBackgroundMusic()
        core.data.musicPlayer!.stop()
        gameScene.playSound("gameover.mp3")
        gameScene.animateCollapsingLines(theworddrop.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            self.gameScene.stopBackgroundMusic()
            let startViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StartMenuViewController") as! StartMenuViewController
            self.performSegueWithIdentifier("gameoverSegue", sender: self)
            // self.presentViewController(startViewController, animated: true, completion: nil)
        }
    }
    
    func gameDidLevelUp(theworddrop: TheWordDrop) {
        theworddrop.level = UInt32(core.data.level)
        levelLabel.text = "\(theworddrop.level)"
        
        gameScene.animateLevelUp(Int(theworddrop.level))
        
        if gameScene.tickLengthMillis >= 10 {
            gameScene.tickLengthMillis -= 10
        } else if gameScene.tickLengthMillis > 0 {
            gameScene.tickLengthMillis -= 1
        } else {
            gameScene.tickLengthMillis = 1
        }
        
        self.tilesLabel.text = "\(core.data.letterQueue.count)"
        gameScene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(theworddrop: TheWordDrop) {
        gameScene.stopTicking()
        gameScene.redrawShape(theworddrop.fallingShape!) {
            theworddrop.letShapeFall()
        }
        
        gameScene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(theworddrop: TheWordDrop) {
        gameScene.stopTicking()
        self.view.userInteractionEnabled = false
        
        let removedWords = theworddrop.removeCompletedWords()
        if removedWords.tilesRemoved.count > 0 {
            self.scoreLabel.text = "\(theworddrop.score)"
            
            // TODO: Add class var defining how many words to list in found word panel
            //       Populate based on word list panel height
            while (theworddrop.lastWords.count > 14) {
                theworddrop.lastWords.removeAtIndex(0)
            }
            
            var wordList = "\n".join(reverse(theworddrop.lastWords))
            self.lastWord.text = "\(wordList)"
            self.tilesLabel.text = "\(core.data.letterQueue.count)"
            
            gameScene.animateFoundWords(core.data.queuedBlocks)
            core.data.queuedBlocks.removeAll()
            gameScene.animateCollapsingLines(removedWords.tilesRemoved, fallenBlocks:removedWords.fallenBlocks) {
            
                self.gameShapeDidLand(theworddrop)
            }
            gameScene.playSound("bomb2.mp3")
        } else {
            nextShape()
        }
    }
    
    // #3
    func gameShapeDidMove(theworddrop: TheWordDrop) {
        if Int(theworddrop.level) != core.data.level {
            gameDidLevelUp(theworddrop)
        }
        gameScene.redrawShape(theworddrop.fallingShape!) {}
    }
}
