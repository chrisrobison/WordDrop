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

class GameViewController: UIViewController, TheWordDropDelegate, UIGestureRecognizerDelegate, StartSceneDelegate {
    var scene: GameScene!
    var theworddrop:TheWordDrop!
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var tilesLabel: UILabel!
    @IBOutlet weak var lastWord: UILabel!
    @IBAction func settingsAction(sender: UIButton) {
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        var transition:SKTransition = SKTransition.pushWithDirection(.Left, duration: 1)
        
        core.data.settingsScene?.scaleMode = .AspectFill
        skView.presentScene(core.data.settingsScene)
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
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    func didMoveToView(view:SKView) {
    
    }

    func startSceneDidFinish(myScene: StartScene, command: String) {
        myScene.view!.removeFromSuperview()
        
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
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
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
            theworddrop.beginGame()
        }
    }
    
    func gameDidLevelUp(theworddrop: TheWordDrop) {
        theworddrop.level = UInt32(core.data.level)
        levelLabel.text = "\(theworddrop.level)"
        
        scene.animateLevelUp(Int(theworddrop.level))
        
        if scene.tickLengthMillis >= 50 {
            scene.tickLengthMillis -= 50
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        // core.data.initLetters(Int(ceil(Double(theworddrop.level) / 5)))
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
