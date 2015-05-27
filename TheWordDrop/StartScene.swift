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
        let replayMessage = "Start Game"
        
        var label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = message
        label.fontSize = 30
        label.fontColor = SKColor.yellowColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(label)
        
        //4
        var replayButton = SKLabelNode(fontNamed: "AvenirNext-Medium")
        replayButton.text = replayMessage
        replayButton.fontSize = 30
        replayButton.fontColor = SKColor.whiteColor()
        replayButton.position = CGPointMake(self.size.width/2, 50)
        replayButton.name = "replay"
        
        self.addChild(replayButton)
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
