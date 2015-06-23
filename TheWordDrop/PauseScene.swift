//
//  PauseScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 6/20/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

//
//  PauseScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 5/22/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import UIKit
import SpriteKit

protocol PauseSceneDelegate {
    func pauseSceneDidFinish(myScene: PauseScene, command:String)
}

class PauseScene: SKScene {
    var thisDelegate: PauseSceneDelegate?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //1
        self.backgroundColor = SKColor.clearColor()
        
        var logo = SKSpriteNode(imageNamed: "AltLogo")
        logo.position = CGPointMake(self.size.width / 2, self.size.height - (self.size.height * 0.2))
        self.addChild(logo)
        
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        var buttons = ["New Game", "Options", "Help", "About"]
        var btn:UIButton
        
        for idx in 0...buttons.count - 1 {
            btn = makeButton(buttons[idx], btnCount: CGFloat(idx))
            self.view!.addSubview(btn)
        }
    }
    
    func makeButton(text: String, btnCount: CGFloat) -> UIButton {
        let leftMargin = (core.data.screenWidth / 2) / 2
        let btnHeight = core.data.screenHeight * 0.08
        var topMargin = core.data.screenHeight * 0.33
        var spacing = btnCount * (btnHeight + (btnHeight / 2))
        topMargin += spacing
        
        let myButton = UIButton(frame: CGRectMake(CGFloat(leftMargin), CGFloat(topMargin), CGFloat(core.data.screenWidth / 2), CGFloat(btnHeight)))
        myButton.backgroundColor = UIColor(hue: 206.0/360.0, saturation: 0.66, brightness: 0.5, alpha: 1.0)
        myButton.setTitle(text, forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchDown)
        myButton.layer.cornerRadius = 10
        
        return myButton
    }
    
    func buttonAction(sPauseer:UIButton) {
        if sPauseer.currentTitle=="Play Again" {
            // close PauseScene and start the game again
            self.thisDelegate!.pauseSceneDidFinish(self, command: "restart")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
