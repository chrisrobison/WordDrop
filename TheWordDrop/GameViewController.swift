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

class GameViewController: UIViewController, TheWordDropDelegate, UIGestureRecognizerDelegate {
    var scene: GameScene!, theworddrop:TheWordDrop!, panPointReference:CGPoint?,
    gameScene: GameScene!,
    startView: SKView?
    
    var views = [String:SKView]()
    
    let transition = SKTransition.pushWithDirection(.Left, duration: NSTimeInterval(3.0))
    
        //flipHorizontalWithDuration(NSTimeInterval(3.0))
//        moveInWithDirection(.Down, duration: NSTimeInterval(3.0))
        // revealWithDirection(SKTransitionDirection.Down, duration: 2.0)
    var skView:SKView!
    
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
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        scene = gameScene
        
        gameScene.tick = didTick
        
        theworddrop = TheWordDrop()
        theworddrop.delegate = self
        theworddrop.beginGame()

        adjustFontsForScreenSize()

        skView.presentScene(gameScene, transition: transition)
        
    }

    func adjustFontsForScreenSize() {
        var fontAdjustment = 0
        var screenSize = UIScreen.mainScreen().bounds.size
        
        if screenSize.height == 480 {
            core.data.screenSize = 480
            println("Detected iPhone 4/4s : screenSize=480")
            // iPhone 4
            fontAdjustment = -2
        } else if screenSize.height == 568 {
            core.data.screenSize = 568
            println("Detected iPhone 5/5s : screenSize=568")
            // IPhone 5
            fontAdjustment = -1
        } else if screenSize.width == 375 {
            println("Detected iPhone 6 : screenSize=375")
            core.data.screenSize = 375
            // iPhone 6
            fontAdjustment = 1
        } else if screenSize.width == 414 {
            println("Detected iPhone 6+ : screenSize=414")
            core.data.screenSize = 414
            // iPhone 6+
            fontAdjustment = 3
        } else if screenSize.width == 768 {
            println("Detected iPad : screenSize=768")
            core.data.screenSize = 768
            // iPad
            fontAdjustment = 10
            
            NumColumns = 11
            PreviewColumn = 11
            
        }
        
        for lab in [self.scoreLabel, self.levelLabel, self.tilesLabel, self.scoreTitle, self.levelTitle, self.tilesTitle, self.wordsLabel] {
            let f = lab.font
            let s = lab.frame.size
            println("\(lab.text) size: \(s)")
            println("Adjusting \(lab.text) from \(f.pointSize) to \(f.pointSize + CGFloat(fontAdjustment))")
            lab.font = f.fontWithSize(f.pointSize + CGFloat(fontAdjustment))
        }
    }
    
    func didMoveToView(view:SKView) {
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
            if abs(currentPoint.x - originalPoint.x) > (core.data.BlockSize * 0.9) {
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
        gameScene.playSound("gameover.mp3")
        core.data.musicPlayer?.stop()
        gameScene.animateCollapsingLines(theworddrop.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            // self.showStart()
            
            let startViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StartMenuViewController") as! StartMenuViewController
            self.performSegueWithIdentifier("StartSegue", sender: self)
            // self.presentViewController(startViewController, animated: true, completion: nil)
        }
    }
    
    func gameDidLevelUp(theworddrop: TheWordDrop) {
        theworddrop.level = UInt32(core.data.level)
        levelLabel.text = "\(theworddrop.level)"
        
        gameScene.animateLevelUp(Int(theworddrop.level))
        
        if gameScene.tickLengthMillis >= 100 {
            gameScene.tickLengthMillis -= 50
        } else if gameScene.tickLengthMillis > 0 {
            gameScene.tickLengthMillis -= 10
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
            
            while (theworddrop.lastWords.count > 14) {
                theworddrop.lastWords.removeAtIndex(0)
            }
            
            var wordList = "\n".join(theworddrop.lastWords)
            self.lastWord.text = "\(wordList)"
            self.tilesLabel.text = "\(core.data.letterQueue.count)"
            
            gameScene.animateFoundWords(core.data.queuedBlocks)
            core.data.queuedBlocks.removeAll()
            gameScene.animateCollapsingLines(removedWords.tilesRemoved, fallenBlocks:removedWords.fallenBlocks) {
            
                self.gameShapeDidLand(theworddrop)
            }
            gameScene.playSound("bomb.mp3")
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
