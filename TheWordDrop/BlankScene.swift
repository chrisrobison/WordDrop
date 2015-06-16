//
//  StartScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 5/22/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//import UIKit
import SpriteKit


class BlankScene: SKScene {    
    override init(size: CGSize) {
        super.init(size: size)
        
        
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)

//        backgroundColor = SKColor.purpleColor()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}