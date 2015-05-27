//
//  GameScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 4/18/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import SpriteKit

let BlockSize:CGFloat = 32


let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let pointsLayer = SKNode()
    let previewLayer = SKNode()
    
    let LayerPosition = CGPoint(x: 0, y: 0)

    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?
    var gameOverView: SKView?
    

    var textureCache = Dictionary<String, SKTexture>()

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        // let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(self.size.width, self.frame.height))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
    
        var x = self.frame.height
        
        shapeLayer.position = CGPoint(x:0, y:0)
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        let previewWidth = 60,
            previewTop = 128
        println("\(self.size.width)x\(self.size.height)")
        
        let previewShape = SKShapeNode(rectOfSize: CGSize(width:62.0, height:92.0), cornerRadius:5)
        previewShape.position = CGPoint(x:30, y:-47)
        previewShape.fillColor = UIColor.whiteColor()
        previewShape.strokeColor = UIColor.clearColor()
        
        let previewShape2 = SKShapeNode(rectOfSize: CGSize(width:62.0, height:92.0), cornerRadius:5)
        previewShape2.position = CGPoint(x:30, y:-44)
        previewShape2.fillColor = UIColor.blackColor()
        previewShape2.strokeColor = UIColor.clearColor()

        let previewNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width:62, height:96))
        previewNode.anchorPoint = CGPoint(x:0, y:1.0)
        previewNode.position = CGPoint(x:self.size.width - 62, y: -66)
        
        previewNode.addChild(previewShape)
        previewNode.addChild(previewShape2)
        
        gameLayer.addChild(previewNode)
        
        core.data.settingsScene = StartScene(size: self.size)

        runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))

    }

    override func didMoveToView(view: SKView) {
        self.gameOverView = SKView(
            frame: CGRectMake(
                self.frame.size.width/4, self.frame.size.height/4,
                self.frame.size.width/2, self.frame.size.height/2))
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastTick == nil {
            return
        }
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            lastTick = NSDate()
            tick?()
        }
    }

    func playSound(sound:String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x: CGFloat = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y: CGFloat = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        for (idx, block) in enumerate(shape.blocks) {
            // #4
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // #5
            sprite.position = pointForColumn(block.column, row:block.row - 1)
            
            var myletter = SKLabelNode(fontNamed: "AvenirNext-Bold");
            myletter.text = block.letter
            myletter.fontSize = 22
            myletter.position = CGPoint(x:-1.5, y:-8)
            myletter.fontColor = SKColor.blackColor()
            
            sprite.addChild(myletter)
            
            var myvalue = SKLabelNode(fontNamed: "AvenirNext-Medium");
            myvalue.text = "\(LetterValues[myletter.text]!)"
            myvalue.fontSize = 7
            myvalue.position = CGPoint(x:8.75, y:-12.5)
            myvalue.fontColor = SKColor.blackColor()
            
            sprite.addChild(myvalue)
            sprite.zPosition = 50
            
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            /*
            var previewBlock = sprite
            var xlate = shape.blockRowColumnPositions[shape.orientation]
            
            previewBlock.position = CGPoint(x: (8 - block.column) * 32, y: (4 - block.row) * 32)
            previewLayer.addChild(previewBlock)
            */
            // Animation
            sprite.alpha = 0
            // #6
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row - 1), duration: NSTimeInterval(0.4))
            moveAction.timingMode = .EaseOut
    
            let scaleAction = SKAction.scaleTo(0.5, duration: NSTimeInterval(0.4))
            scaleAction.timingMode = .EaseOut
            
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.4)
            fadeInAction.timingMode = .EaseOut
            
            sprite.runAction(SKAction.group([moveAction, scaleAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:() -> ()) {
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: NSTimeInterval(0.2))
            let scaleToAction = SKAction.scaleTo(1.0, duration: NSTimeInterval(0.2))
            moveToAction.timingMode = .EaseOut
            sprite.runAction(
                SKAction.group([moveToAction, scaleToAction, SKAction.fadeAlphaTo(1.0, duration: NSTimeInterval(0.2))]), completion:nil)
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:() -> ()) {
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(moveToAction, completion: nil)
        }
        runAction(SKAction.waitForDuration(0.05), completion: completion)
    }
    
    func animateLevelUp(level:Int) {
        let sprite = SKSpriteNode()
        sprite.position = pointForColumn(4, row:7)
        
        var myword = SKLabelNode(fontNamed: "AvenirNext-Bold");
        myword.text = "LEVEL \(level)"
        myword.fontSize = 24
        myword.position = CGPoint(x:0, y:0)
        myword.fontColor = SKColor.whiteColor()
        
        sprite.addChild(myword)
        sprite.zPosition = 100
        
        shapeLayer.addChild(sprite)

        var actions = Array<SKAction>();
        var delay = NSTimeInterval(3)

        actions.append(SKAction.fadeOutWithDuration(NSTimeInterval(3)))
        actions.append(SKAction.scaleTo(6.0, duration: NSTimeInterval(3)))
        
        let group = SKAction.group(actions);
        sprite.runAction(SKAction.sequence([SKAction.scaleTo(2.0, duration: NSTimeInterval(1)), SKAction.waitForDuration(delay), group]))
    }
    
    func animateFoundWords(queuedBlocks:[(String,Int,Array<Block>)]) {
        var i=1
        for (word, point, blocks) in queuedBlocks {
            let sprite = SKSpriteNode()
            sprite.color = SKColor.blueColor()
            sprite.colorBlendFactor = 1.0
            
            var block = blocks[0]
            var col = block.column
            
            // shift column origin if too close to left or right
            if col < 3 {
                col = col + (4 - col)
            }
            
            sprite.position = pointForColumn(col, row:block.row - i)
        
            var myword = SKLabelNode(fontNamed: "AvenirNext-Bold");
            myword.text = "\(word) +\(point)"
            myword.fontSize = 12
            myword.position = CGPoint(x:0, y:0)
            myword.fontColor = SKColor.whiteColor()

            sprite.addChild(myword)
            sprite.zPosition = 50
            
            shapeLayer.addChild(sprite)
            
            var actions = Array<SKAction>();
            var delay = (NSTimeInterval(i) * 0.75)
            
            i++
            
            actions.append(SKAction.fadeOutWithDuration(NSTimeInterval(2)))
            actions.append(SKAction.scaleTo(5.0, duration: NSTimeInterval(2)))
            actions.append(SKAction.moveByX(0.0, y:300.0, duration: NSTimeInterval(2)))
            
            let group = SKAction.group(actions);
            sprite.runAction(
                    SKAction.sequence([
                        SKAction.group([
                            SKAction.scaleTo(3.0, duration: NSTimeInterval(1)),
                            SKAction.colorizeWithColor(SKColor.whiteColor(), colorBlendFactor: 1.0, duration: NSTimeInterval(1))]),
                        group]))
            
            
        }
    }
    
    func animateCollapsingLines(tilesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:() -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for (columnIdx, column) in enumerate(fallenBlocks) {
            for (blockIdx, block) in enumerate(column) {
                let newPosition = pointForColumn(block.column, row: block.row)
                let sprite = block.sprite!
                
                let delay = (NSTimeInterval(columnIdx) * 0.05) + (NSTimeInterval(blockIdx) * 0.05)
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.05)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                
                //println("Dropping block - delay:\(delay) duration:\(duration)")
                
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for (rowIdx, word) in enumerate(tilesToRemove) {
            for (blockIdx, block) in enumerate(word) {
                // #4
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(block.column, row: block.row)
                point = CGPointMake(point.x + (goLeft ? -randomRadius : randomRadius), point.y)
                
                let randomDuration = NSTimeInterval(arc4random_uniform(2)) + 0.75
                // #5
                var startAngle = CGFloat(M_PI)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.followPath(archPath.CGPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .EaseIn
                let sprite = block.sprite!
                // #6
                sprite.zPosition = 100
                sprite.runAction(
                    SKAction.sequence(
                        [SKAction.group([archAction, SKAction.fadeOutWithDuration(NSTimeInterval(randomDuration))]),
                            SKAction.removeFromParent()]))
            }
        }
        // #7
        runAction(SKAction.waitForDuration(longestDuration), completion:completion)
    }
}

