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

class GameViewController: UIViewController, TheWordDropDelegate, UIGestureRecognizerDelegate, StartSceneDelegate {
    var scene: GameScene!
    var theworddrop:TheWordDrop!
    var panPointReference:CGPoint?
    var startView: SKView?
    var startScene: StartScene?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreTitle: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelTitle: UILabel!
    @IBOutlet weak var tilesLabel: UILabel!
    @IBOutlet weak var tilesTitle: UILabel!
    @IBOutlet weak var lastWord: UILabel!
    @IBOutlet weak var infoPanel: UIView!
    @IBAction func settingsAction(sender: UIButton) {
    
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        self.scene.view?.addSubview(self.startView!)

        // var transition:SKTransition = SKTransition.pushWithDirection(.Left, duration: 1)
        
        // core.data.settingsScene?.scaleMode = .AspectFill
        // skView.presentScene(core.data.settingsScene)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        
        theworddrop = TheWordDrop()
        theworddrop.delegate = self
        theworddrop.beginGame()
        
        adjustFontsForScreenSize()
        
        // Present the scene.
        skView.presentScene(scene)
        
        self.startView = SKView( frame: CGRectMake(0, 0, scene.frame.size.width, scene.frame.size.height) )
        
        self.startScene = StartScene(size: CGSizeMake(scene.frame.size.width, scene.frame.size.height))
        self.startScene!.thisDelegate = self
        self.startView!.presentScene(startScene)

        core.data.settingsScene = startScene
        
    }
    
    func adjustFontsForScreenSize() {
        var fontAdjustment = 0
        
        if UIScreen.mainScreen().bounds.size.height == 480 {
            core.data.screenSize = 480
            // iPhone 4
            fontAdjustment = -2
        } else if UIScreen.mainScreen().bounds.size.height == 568 {
            core.data.screenSize = 568
            // IPhone 5
            fontAdjustment = -2
        } else if UIScreen.mainScreen().bounds.size.width == 375 {  // *Perfect*
            core.data.screenSize = 375
            // iPhone 6
            fontAdjustment = 0
        } else if UIScreen.mainScreen().bounds.size.width == 414 {  // *Perfect*
            core.data.screenSize = 414
            // iPhone 6+
            fontAdjustment = 3
        } else if UIScreen.mainScreen().bounds.size.width == 768 {  // *Perfect*
            core.data.screenSize = 768
            // iPad
            fontAdjustment = 0
        }
        
        for lab in [self.scoreLabel, self.levelLabel, self.tilesLabel, self.scoreTitle, self.levelTitle, self.tilesTitle] {
            let f = lab.font
            lab.font = f.fontWithSize(f.pointSize + CGFloat(fontAdjustment))
        }
    }
    
    func didMoveToView(view:SKView) {
        println("didMoveToView called in GameViewController")
    }

    func startSceneDidFinish(myScene: StartScene, command: String) {
        println("GameViewController.startSceneDidFinish called")
        myScene.view!.removeFromSuperview()
        // skView.presentScene(scene)
        if command == "restart" {
            scene.tick = didTick
            theworddrop.beginGame()
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
        theworddrop.rotateShape()
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
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                // #2
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
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
        
        scene.animateLevelUp(Int(theworddrop.level))
        
        scene.tickLengthMillis = TickLengthLevelOne

        // The following is false when restarting a new game
        if theworddrop.nextShape != nil && theworddrop.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(theworddrop.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(theworddrop: TheWordDrop) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(theworddrop.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            //theworddrop.beginGame()
            self.view.userInteractionEnabled = true
            self.scene.view?.addSubview(self.startView!)
        }
    }
    
    func gameDidLevelUp(theworddrop: TheWordDrop) {
        theworddrop.level = UInt32(core.data.level)
        levelLabel.text = "\(theworddrop.level)"
        
        scene.animateLevelUp(Int(theworddrop.level))
        
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 50
        } else if scene.tickLengthMillis > 0 {
            scene.tickLengthMillis -= 10
        } else {
            scene.tickLengthMillis = 1
        }
        
        self.tilesLabel.text = "\(core.data.letterQueue.count)"
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(theworddrop: TheWordDrop) {
        scene.stopTicking()
        scene.redrawShape(theworddrop.fallingShape!) {
            theworddrop.letShapeFall()
        }
        
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(theworddrop: TheWordDrop) {
        scene.stopTicking()
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
            
            scene.animateFoundWords(core.data.queuedBlocks)
            core.data.queuedBlocks.removeAll(keepCapacity: true)
            scene.animateCollapsingLines(removedWords.tilesRemoved, fallenBlocks:removedWords.fallenBlocks) {
            
                self.gameShapeDidLand(theworddrop)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #3
    func gameShapeDidMove(theworddrop: TheWordDrop) {
        if Int(theworddrop.level) != core.data.level {
            gameDidLevelUp(theworddrop)
        }
        scene.redrawShape(theworddrop.fallingShape!) {}
    }
}
