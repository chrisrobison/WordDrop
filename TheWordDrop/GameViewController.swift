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
    var scene: GameScene!, theworddrop:TheWordDrop!, panPointReference:CGPoint?,
        startView: SKView?, startScene: StartScene!, gameScene: GameScene!
    
    let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
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
    @IBAction func settingsAction(sender: UIButton) {
            showStart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        core.data.viewCache["words"] = wordPanel
        core.data.viewCache["score"] = scorePanel
        
        core.data.settingsScene = startScene
        
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        scene = gameScene
        adjustFontsForScreenSize()
        
        skView.presentScene(gameScene, transition: transition)

        startView = SKView(frame: skView.bounds)
        startScene = StartScene(size: skView.bounds.size)
        startScene!.thisDelegate = self
        startView?.presentScene(startScene)
        
        // Present the scene.
        skView.addSubview(startView!)
        
        
    }

    func startGame() {
        startView?.removeFromSuperview()
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.scaleMode = .AspectFill

        gameScene.tick = didTick

        theworddrop = TheWordDrop()
        theworddrop.delegate = self
        theworddrop.beginGame()
        
        // Present the scene.
        skView.presentScene(gameScene)
    }
    
    func showStart() {
        let startScene = StartScene(size: self.view.frame.size)
        startScene.scaleMode = SKSceneScaleMode.AspectFill
        
        skView.presentScene(startScene, transition:transition)
    }

    func showHelp() {
        let helpScene = HelpScene(size: self.view.frame.size)
        helpScene.scaleMode = SKSceneScaleMode.AspectFill
        
        skView.presentScene(helpScene, transition:transition)
    }

    func showAbout() {
        let aboutScene = AboutScene(size: self.view.frame.size)
        aboutScene.scaleMode = SKSceneScaleMode.AspectFill
        
        skView.presentScene(aboutScene, transition:transition)
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
        } else if UIScreen.mainScreen().bounds.size.width == 375 {
            core.data.screenSize = 375
            // iPhone 6
            fontAdjustment = 0
        } else if UIScreen.mainScreen().bounds.size.width == 414 {
            core.data.screenSize = 414
            // iPhone 6+
            fontAdjustment = 3
        } else if UIScreen.mainScreen().bounds.size.width == 768 {
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

    func handleNavCommands(command: String) {
        switch command {
            case "start":
                return startGame()
            case "help":
                return showHelp()
            case "about":
                return showAbout()
            default:
                return startGame()
        }
       
    }
    
    func startSceneDidFinish(myScene: StartScene, command: String) {
        println("GameViewController.startSceneDidFinish called")
        myScene.view!.removeFromSuperview()

        handleNavCommands(command)
    }
    
    func helpSceneDidFinish(myScene: HelpScene, command: String) {
        println("GameViewController.helpSceneDidFinish called")
        myScene.view!.removeFromSuperview()
        handleNavCommands(command)
    }
    
    func aboutSceneDidFinish(myScene: AboutScene, command: String) {
        println("GameViewController.aboutSceneDidFinish called")
        myScene.view!.removeFromSuperview()
        handleNavCommands(command)
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
        gameScene.animateCollapsingLines(theworddrop.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            //theworddrop.beginGame()
            self.view.userInteractionEnabled = true
            self.gameScene.view?.addSubview(self.startView!)
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
