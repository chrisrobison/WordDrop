//
//  StartScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 5/22/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import UIKit
import SpriteKit

protocol StartSceneDelegate {
    func startSceneDidFinish(myScene: StartScene, command:String)
}

class StartScene: SKScene {
    var thisDelegate: StartSceneDelegate?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //1
        self.backgroundColor = SKColor.blackColor()
        
        let message = "Game Over"
        
        var label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = message
        label.fontSize = 36
        label.fontColor = SKColor.yellowColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(label)
        
    }
    
    override func didMoveToView(view: SKView) {
        println("didMoveToView called in StartScene")
        
        let leftMargin = (view.bounds.width/2) / 2
        let topMargin = view.bounds.height/2

        let playAgainButton = UIButton(frame: CGRectMake(leftMargin, topMargin + 30, view.bounds.width / 2, 50))
        playAgainButton.backgroundColor = UIColor(hue: 206.0/360.0, saturation: 0.66, brightness: 0.5, alpha: 1.0)
        playAgainButton.setTitle("Play Again", forState: UIControlState.Normal)
        playAgainButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        playAgainButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchDown)
        self.view!.addSubview(playAgainButton)
        
        
    }
    
    func buttonAction(sender:UIButton) {
        if sender.currentTitle=="Play Again" {
            // close StartScene and start the game again
            self.thisDelegate!.startSceneDidFinish(self, command: "restart")
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location) //1
            if node.name == "replay" { //2
                let reveal : SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: self.view!.bounds.size)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene, transition: reveal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
