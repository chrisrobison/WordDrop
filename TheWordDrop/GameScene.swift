//
//  GameScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 4/18/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import SpriteKit
import AVFoundation

let TickLengthLevelOne = NSTimeInterval(600 - (core.data.level * 50))

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

class GameScene: SKScene {
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let pointsLayer = SKNode()
    let previewLayer = SKNode()
    let wordLayer = SKNode()
    let scoreLayer = SKNode()
    let infoLayer = SKNode()
    var BlockSize:CGFloat = 32
    
    let LayerPosition = CGPoint(x: 0, y: 0)

    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne - (core.data.prefs["skill"] as! Double * 100)
    var lastTick:NSDate?
    var gameOverView: SKView?
    var startSceneView: SKView?
    var sounds = [String:SKAction]()
    var textureCache = Dictionary<String, SKTexture>()

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.BlockSize = self.size.height / CGFloat(NumRows)
        
        if (core.data.screenSize == 480) {
            self.BlockSize = 28
        }
        
        //println("BlockSize: \(BlockSize)")
        
        self.anchorPoint = CGPointMake(0, 0)
        //self.BlockSize = self.size.width / 10
        core.data.BlockSize = self.BlockSize
        core.data.screenWidth = self.size.width
        core.data.screenHeight = self.size.height
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = anchorPoint
        background.zPosition = -10
        addChild(background)
        addChild(gameLayer)
        
        var gameBoardTexture:SKTexture
        if (core.data.screenSize == 768) {
            gameBoardTexture = SKTexture(imageNamed: "gameboard-768")
        } else {
            gameBoardTexture = SKTexture(imageNamed: "gameboard")
        }
        // let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(self.size.width, self.frame.height))
        gameBoard.anchorPoint = anchorPoint
        gameBoard.position = LayerPosition
        gameBoard.zPosition = 0
        
        var previewMultiplier = 0.20
        var xAdjust = CGFloat(0.0)
        var yAdjust = CGFloat(10.0)
        var yAdjust2 = CGFloat(3.0)
        var yMultiplier = CGFloat(0.41)
        
        if (core.data.screenSize == 480) {
            yAdjust = -4
            yMultiplier = CGFloat(0.39)
            yAdjust2 = 2
        }
        
        if (core.data.screenSize == 568) {
            yAdjust = 0
        }
        
        if (core.data.screenSize == 414) {
            yAdjust = 0
        }
        
        if (core.data.screenSize == 375) {
            yAdjust = 0
        
        }
        
        if (core.data.screenSize == 768) {
            previewMultiplier = 0.17
            xAdjust = CGFloat(6)
            yAdjust = -18
            yAdjust2 = 18
        }
        
        let previewWidth = self.frame.size.width * CGFloat(previewMultiplier)
        
        shapeLayer.position = CGPoint(x:0, y:0)
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        let  previewTop = 92.0
        
        previewLayer.position = LayerPosition
        
        // println("screenSize: \(core.data.screenSize)\nyAdjust: \(yAdjust)\nyMultiplier: \(yMultiplier)\nxAdjust: \(xAdjust)")
        
        var previewNode = makeInfoPanel(previewWidth - 6, height: previewWidth)
        previewNode.position = CGPoint(x:self.size.width - (previewWidth + xAdjust) + 3, y: -((previewWidth * 2) + yAdjust2))
        
        var wordsNode = makeInfoPanel(previewWidth - 6, height: core.data.screenHeight * yMultiplier)
        wordsNode.position = CGPoint(x:self.size.width - (previewWidth + xAdjust) + 3, y: -(core.data.screenHeight * 0.75) + yAdjust)
        
        var scoreNode = makeInfoPanel(previewWidth - 6, height: core.data.screenHeight * 0.21)
        scoreNode.position = CGPoint(x:self.size.width - ((previewWidth) + xAdjust) + 3, y: -(core.data.screenHeight - 8))
        
        
        previewLayer.addChild(previewNode)
        previewLayer.addChild(wordsNode)
        previewLayer.addChild(scoreNode)
        
        gameLayer.addChild(previewLayer)
        
        gameLayer.zPosition = 0

        // runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))
        self.playBackgroundMusic()
        self.sounds = preloadSounds(["bomb2.mp3","drop.mp3","gameover.mp3","levelup.mp3"])
        
    }

    func playBackgroundMusic() {
        
        if core.data.musicPlayer == nil {
            var bgsoundPath:NSURL = NSBundle.mainBundle().URLForResource("theme", withExtension: "mp3")!
        
            var error: NSError?
            core.data.musicPlayer = AVAudioPlayer(contentsOfURL: bgsoundPath, error: &error)
            core.data.musicPlayer!.volume = 0.5
            core.data.musicPlayer!.numberOfLoops = -1
            core.data.musicPlayer!.prepareToPlay()
        }
        if core.data.prefs["bgmusic"] as! Bool == true {
            core.data.musicPlayer!.play()
        } else {
            core.data.musicPlayer!.stop()
        }
    }
    
    func stopBackgroundMusic() {
        core.data.musicPlayer!.stop()
    }
    
    func preloadSounds(sounds: [String]) -> [String:SKAction] {
        var cache = [String:SKAction]()
        
        for sf in sounds {
            cache[sf] = SKAction.playSoundFileNamed(sf, waitForCompletion: false)
        }
        
        return cache
    }
    
    func playSound(sound:String) {
        if (core.data.prefs["soundeffects"] as! Bool == true) {
            runAction(sounds[sound])
        }
    }
    
    func makeInfoPanel(width: CGFloat, height: CGFloat) -> SKSpriteNode {
        let previewShape = SKShapeNode()
        previewShape.path = UIBezierPath(roundedRect: CGRect(x:0, y:0, width: width, height: height), cornerRadius: 6).CGPath
        previewShape.position = CGPoint(x:0, y:-3)
        previewShape.fillColor = UIColor.whiteColor()
        previewShape.strokeColor = UIColor.clearColor()
        
        let previewShape2 = SKShapeNode()
        previewShape2.path = UIBezierPath(roundedRect: CGRect(x:0, y:0, width: width, height: height), cornerRadius: 6).CGPath
        previewShape2.position = CGPoint(x:0, y:0)
        previewShape2.fillColor = UIColor.blackColor()
        previewShape2.strokeColor = UIColor.clearColor()
        
        let previewNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width:width - 8, height:height + 3))
        previewNode.anchorPoint = CGPoint(x:0, y:1.0)
        
        previewNode.addChild(previewShape)
        previewNode.addChild(previewShape2)
        
        previewNode.zPosition = 10
        return previewNode
    }
    
    func newSpark() -> SKEmitterNode {
        let sparkpath:NSString = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")!
        let newspark = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkpath as String) as! SKEmitterNode
        return newspark
    }
    
    override func didMoveToView(view: SKView) {
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

    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x: CGFloat = LayerPosition.x + (CGFloat(column) * BlockSize)
        let y: CGFloat = LayerPosition.y - (CGFloat(row) * BlockSize) - BlockSize
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        let blockRowColumnTranslations = shape.blockRowColumnPositions[shape.orientation]
        var destX = LayerPosition.x + (CGFloat(shape.preview) * BlockSize) + (BlockSize / 2)
        var destY = LayerPosition.y + (CGFloat(shape.row) * BlockSize) - (BlockSize / 2)

        for (idx, block) in enumerate(shape.blocks) {
            var CGBlockSize = CGSize(width: BlockSize, height: BlockSize)
            let sprite = SKShapeNode()
            sprite.path = UIBezierPath(roundedRect: CGRectMake(0, 0, BlockSize, BlockSize), cornerRadius: 5).CGPath
            sprite.fillColor = block.spriteColor
            
            sprite.strokeColor = UIColor.darkGrayColor()
            sprite.lineWidth = 1
            sprite.position = pointForColumn(NumColumns, row:1)
            
            var myletter = SKLabelNode(fontNamed: "AvenirNext-Bold");
            myletter.text = block.letter
            
            //       original = 22
            //                  28
            myletter.fontSize = self.size.height * 0.039 // 35
            //                          x:-1.5, y:-8
            //
            myletter.position = CGPoint(x:self.size.height * 0.026, y:self.size.height * 0.015)
            myletter.fontColor = SKColor.blackColor()
            
            sprite.addChild(myletter)
            
            var myvalue = SKLabelNode(fontNamed: "AvenirNext-Medium");
            myvalue.text = "\(LetterValues[myletter.text]!)"
            //                  7
            //                 12
            myvalue.fontSize = self.size.height * 0.013 // 15
            //                         x:8.75, y:-12.5
            //                         x:12,   y:-15
            myvalue.position = CGPoint(x:self.size.height * 0.045, y:3)
            myvalue.fontColor = SKColor.blackColor()
            
            sprite.addChild(myvalue)
            sprite.zPosition = 20
            
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            var newX = destX
            var newY = destY
            
            if let colDiff = blockRowColumnTranslations?[idx].0 {
                newX = CGFloat(newX) + (CGFloat(colDiff) * CGFloat(BlockSize / 2)) + (BlockSize / 2)
            }
            
            if let rowDiff = blockRowColumnTranslations?[idx].1 {
                newY = CGFloat(newY) + (CGFloat(rowDiff) * CGFloat(BlockSize / 2)) - 10
            }
            
            let moveAction = SKAction.moveTo(CGPointMake(newX, -newY), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
    
            let scaleAction = SKAction.scaleTo(0.5, duration: NSTimeInterval(0.5))
            scaleAction.timingMode = .EaseOut
            
            let fadeInAction = SKAction.fadeAlphaTo(1.0, duration: 0.15)
            fadeInAction.timingMode = .EaseOut
            
            sprite.runAction(SKAction.group([moveAction, scaleAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:() -> ()) {
        shape.column = shape.start
        shape.repositionBlocks(shape.column, row:shape.row)
       
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: NSTimeInterval(0.2))
            let scaleToAction = SKAction.scaleTo(1.0, duration: NSTimeInterval(0.2))
            moveToAction.timingMode = .EaseOut
            sprite.runAction(
                SKAction.group([moveToAction, scaleToAction]), completion:nil)
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
        let banner = SKSpriteNode()
        banner.position = pointForColumn((NumColumns / 2) + 1, row:7)
        
        var myword = SKLabelNode(fontNamed: "AvenirNext-Bold");
        myword.text = "LEVEL \(level)"
        myword.fontSize = 24
        myword.position = CGPoint(x:0, y:0)
        myword.fontColor = SKColor.whiteColor()
        
        banner.addChild(myword)
        banner.zPosition = 1000
        
        shapeLayer.addChild(banner)

        var actions = Array<SKAction>();
        var delay = NSTimeInterval(3)

        
        actions.append(SKAction.fadeOutWithDuration(NSTimeInterval(3)))
        actions.append(SKAction.scaleTo(6.0, duration: NSTimeInterval(3)))
        
        let group = SKAction.group(actions);
        banner.runAction(SKAction.sequence([SKAction.scaleTo(2.0, duration: NSTimeInterval(1)), SKAction.waitForDuration(delay), group, SKAction.removeFromParent()]))
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
                        group, SKAction.removeFromParent()]))
            
            
        }
    }
    
    func CDRwait(duration: Double) -> SKAction {
        return SKAction.waitForDuration(NSTimeInterval(duration))
    }
    
    func CDRfade(duration: Double) -> SKAction {
        return SKAction.fadeOutWithDuration(NSTimeInterval(duration))
    }
    
    func animateCollapsingLines(tilesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:() -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for (columnIdx, column) in enumerate(fallenBlocks) {
            for (blockIdx, block) in enumerate(column) {
                let newPosition = pointForColumn(block.column, row: block.row)
                let sprite = block.sprite!
                
                var delay = (NSTimeInterval(columnIdx) * 0.05) + (NSTimeInterval(blockIdx) * 0.1)
                var duration = NSTimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                
                //println("Dropping block - block:\(block) duration:\(duration)")
                
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
                
                let randomDuration = NSTimeInterval(arc4random_uniform(3)) + 0.75
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
                sprite.zPosition = 10
                
                var xplode = newSpark()
                xplode.position = pointForColumn(block.column, row: block.row)
                xplode.name = "MyParticle"
                xplode.zPosition = 100
                
                sprite.parent!.addChild(xplode)
                
                var delay = (NSTimeInterval(block.column) * 0.05) + (NSTimeInterval(blockIdx) * 0.1)
                var scale = SKAction.scaleBy(CGFloat(1 + (LetterValues[block.letter]! / 10)), duration: NSTimeInterval(0.5))
                
                var explactions = [ CDRwait(0.75 + delay), CDRfade(0.5), SKAction.removeFromParent()]
                
                xplode.runAction(SKAction.group([scale, SKAction.sequence(explactions)]))
                
                sprite.zPosition = 25
                sprite.runAction(
                    SKAction.sequence(
                        [
                            SKAction.group(
                                [
                                    archAction,
                                    CDRfade(randomDuration)
                                ]
                            ),
                            SKAction.removeFromParent()
                        ]
                    )
                )
            }
        }
    
        runAction(SKAction.waitForDuration(longestDuration), completion:completion)
    }
}

