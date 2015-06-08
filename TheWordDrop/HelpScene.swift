//
//  HelpScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 5/22/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import UIKit
import SpriteKit

protocol HelpSceneDelegate {
    func helpSceneDidFinish(myScene: HelpScene, command:String)
}

class HelpScene: SKScene {
    var thisDelegate: HelpSceneDelegate?
    
    /*
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
    println("didMoveToView called in HelpScene")
    
    let leftMargin = (view.bounds.width/2) / 2
    let topMargin = view.bounds.height/2
    
    let playAgainButton = UIButton(frame: CGRectMake(leftMargin, topMargin + 30, view.bounds.width / 2, 50))
    playAgainButton.backgroundColor = UIColor(hue: 206.0/360.0, saturation: 0.66, brightness: 0.5, alpha: 1.0)
    playAgainButton.setTitle("Play Again", forState: UIControlState.Normal)
    playAgainButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    playAgainButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchDown)
    playAgainButton.layer.cornerRadius = 10
    
    self.view!.addSubview(playAgainButton)
    
    
    }
    */
    override init(size: CGSize) {
        super.init(size: size)
        
        //1
        self.backgroundColor = SKColor(hue: 0.0, saturation: 0.0, brightness: 0.24, alpha: 1.0)
        
        var logo = SKSpriteNode(imageNamed: "AltLogo")
        logo.position = CGPointMake(self.size.width / 2, self.size.height - (self.size.height * 0.2))
        self.addChild(logo)
        
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        var buttons = ["About", "Help", "Options", "New Game"]
        var btn:UIView
        var btnObjects = [UIView]()
        
        for idx in 0...buttons.count-1 {
            btn = makeButton(buttons[idx], btnCount: CGFloat(idx))
            btnObjects.append(btn)
            
            self.view!.addSubview(btn)
        }
    }
    
    func makeButton(text: String, btnCount: CGFloat) -> UIView {
        let leftMargin = (core.data.screenWidth / 2) / 2
        let btnHeight = core.data.screenHeight * 0.08
        var topMargin = core.data.screenHeight - (core.data.screenHeight * 0.18)
        
        var spacing = btnCount * (btnHeight + (btnHeight * 0.75))
        topMargin -= spacing
        println("making button '\(text)' topMargin: \(topMargin) leftMargin: \(leftMargin) btnHeight: \(btnHeight)")
        
        
        let shadowView = UIView(frame: CGRectMake(CGFloat(leftMargin), CGFloat(topMargin), CGFloat(core.data.screenWidth / 2), CGFloat(btnHeight)))
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowRadius = 3
        
        let myButton = UIButton(frame: CGRectMake(0, 0, CGFloat(core.data.screenWidth / 2), btnHeight))
        myButton.backgroundColor = UIColor(hue: 206.0/360.0, saturation: 0.66, brightness: 0.5, alpha: 1.0)
        myButton.setTitle(text, forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 22)
        myButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchDown)
        myButton.layer.cornerRadius = 10
        //myButton.layer.shadowOffset = CGSizeMake(1,1)
        //myButton.layer.shadowRadius = 5
        
        shadowView.addSubview(myButton)
        
        return shadowView
    }
    
    
    func buttonAction(sender:UIButton) {
        if sender.currentTitle=="Play Again" || sender.currentTitle == "New Game" {
            // close HelpScene and start the game again
            self.thisDelegate!.helpSceneDidFinish(self, command: "restart")
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
