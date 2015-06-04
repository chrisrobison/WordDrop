//
//  GameScene.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 4/18/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import SpriteKit
import AVFoundation

let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let pointsLayer = SKNode()
    let previewLayer = SKNode()
    var BlockSize:CGFloat = 32
    var musicPlayer = AVAudioPlayer()
    
    let LayerPosition = CGPoint(x: 0, y: 0)

    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
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
        self.BlockSize = self.size.height / 18
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
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        // let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(self.size.width, self.frame.height))
        gameBoard.anchorPoint = anchorPoint
        gameBoard.position = LayerPosition
        gameBoard.zPosition = 0
        
        let previewWidth = self.frame.size.width * 0.20
        
        shapeLayer.position = CGPoint(x:0, y:0)
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        let  previewTop = 92.0
        println("self.size: \(self.size.width)x\(self.size.height)")
        println("self.frame.size: \(self.frame.size.width)x\(self.frame.size.height)")
        
        previewLayer.position = LayerPosition
        println("previewWidth: \(previewWidth)")
        
        var previewNode = makeInfoPanel(previewWidth)   // Not really passing width, it just happens to be the same size
        previewNode.position = CGPoint(x:self.size.width - (previewWidth / 2), y: -((previewWidth * 2) - (previewWidth / 2) + 3))
        
        //gameLayer.addChild(previewNode)
        previewLayer.addChild(previewNode)
        gameLayer.addChild(previewLayer)
        
        gameLayer.zPosition = 0
        
        var bgsoundPath:NSURL = NSBundle.mainBundle().URLForResource("theme", withExtension: "mp3")!
        
        var error: NSError?
        self.musicPlayer = AVAudioPlayer(contentsOfURL: bgsoundPath, error: &error)
        self.musicPlayer.volume = 0.5
        self.musicPlayer.prepareToPlay()
        self.musicPlayer.play()
        
        // runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))

        self.sounds = preloadSounds(["bomb.mp3","drop.mp3","gameover.mp3","levelup.mp3"])
        
    }

    func newSpark() -> SKEmitterNode {
        let sparkpath:NSString = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")!
        let newspark = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkpath as String) as! SKEmitterNode
        return newspark
    }
    
    func makeInfoPanel(previewWidth: CGFloat) -> SKSpriteNode {
        let previewShape = SKShapeNode(rectOfSize: CGSize(width:previewWidth - 8, height:previewWidth), cornerRadius:6)
        previewShape.position = CGPoint(x:0, y:-3)
        previewShape.fillColor = UIColor.whiteColor()
        previewShape.strokeColor = UIColor.clearColor()
        
        let previewShape2 = SKShapeNode(rectOfSize: CGSize(width:previewWidth - 8, height:previewWidth), cornerRadius:6)
        previewShape2.position = CGPoint(x:0, y:0)
        previewShape2.fillColor = UIColor.blackColor()
        previewShape2.strokeColor = UIColor.clearColor()
        
        let previewNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width:previewWidth - 8, height:previewWidth + 3))
        previewNode.anchorPoint = CGPoint(x:0, y:1.0)
        
        previewNode.addChild(previewShape)
        previewNode.addChild(previewShape2)

        previewNode.zPosition = 10
        return previewNode
    }
    
    func preloadSounds(sounds: [String]) -> [String:SKAction] {
        var cache = [String:SKAction]()
        
        for sf in sounds {
            cache[sf] = SKAction.playSoundFileNamed(sf, waitForCompletion: false)
        }
        
        return cache
    }

    override func didMoveToView(view: SKView) {
        println("didMoveToView called in GameScene")
        
/*        self.startSceneView = SKView(frame: CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height))
        let startScene = StartScene(size: CGSizeMake(self.frame.size.width, self.frame.size.height));
        self.startSceneView!.presentScene(startScene)
        startScene.thisDelegate = self
*/
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
        runAction(sounds[sound])
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
    
    private func newExplosion() -> SKEmitterNode {
        
        let explosion = SKEmitterNode()
        
        let image = UIImage(named:"spark.png")!
        explosion.particleTexture = SKTexture(image: image)
        explosion.particleColor = UIColor.brownColor()
        explosion.numParticlesToEmit = 100
        explosion.particleBirthRate = 450
        explosion.particleLifetime = 2
        explosion.emissionAngleRange = 360
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.xAcceleration = 0
        explosion.yAcceleration = 0
        explosion.particleAlpha = 0.8
        explosion.particleAlphaRange = 0.2
        explosion.particleAlphaSpeed = -0.5
        explosion.particleScale = 0.75
        explosion.particleScaleRange = 0.4
        explosion.particleScaleSpeed = -0.5
        explosion.particleRotation = 0
        explosion.particleRotationRange = 0
        explosion.particleRotationSpeed = 0
        explosion.particleColorBlendFactor = 1
        explosion.particleColorBlendFactorRange = 0
        explosion.particleColorBlendFactorSpeed = 0
        explosion.particleBlendMode = SKBlendMode.Add
        
        return explosion
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        let blockRowColumnTranslations = shape.blockRowColumnPositions[shape.orientation]
        var destX = LayerPosition.x + (CGFloat(shape.column) * BlockSize) + (BlockSize / 2)
        var destY = LayerPosition.y + (CGFloat(shape.row - 1) * BlockSize) + (BlockSize / 2)

        for (idx, block) in enumerate(shape.blocks) {
            var CGBlockSize = CGSize(width: BlockSize, height: BlockSize)
            let sprite = SKShapeNode(rectOfSize: CGBlockSize, cornerRadius: 4.0)
            
            sprite.fillColor = block.spriteColor
            
            sprite.strokeColor = UIColor.darkGrayColor()
            sprite.position = pointForColumn(block.column, row:block.row - 1)
            
            var myletter = SKLabelNode(fontNamed: "AvenirNext-Bold");
            myletter.text = block.letter
            //       original = 22
            //                  28
            myletter.fontSize = self.size.height * 0.039 // 35
            //                          x:-1.5, y:-8
            //
            myletter.position = CGPoint(x:-self.size.height * 0.0026, y:-self.size.height * 0.015)
            myletter.fontColor = SKColor.blackColor()
            
            sprite.addChild(myletter)
            
            var myvalue = SKLabelNode(fontNamed: "AvenirNext-Medium");
            myvalue.text = "\(LetterValues[myletter.text]!)"
            //                  7
            //                 12
            myvalue.fontSize = self.size.height * 0.013 // 15
            //                         x:8.75, y:-12.5
            //                         x:12,   y:-15
            myvalue.position = CGPoint(x:self.size.height * 0.016, y:-self.size.height * 0.022)
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
                newX = CGFloat(newX) + (CGFloat(colDiff) * CGFloat(BlockSize / 2)) + 4 + (BlockSize / 2)
            }
            
            if let rowDiff = blockRowColumnTranslations?[idx].1 {
                newY = CGFloat(newY) + (CGFloat(rowDiff) * CGFloat(BlockSize / 2)) - 10
            }
            
            let moveAction = SKAction.moveTo(CGPointMake(newX, -newY), duration: NSTimeInterval(0.5))
            moveAction.timingMode = .EaseOut
    
            let scaleAction = SKAction.scaleTo(0.5, duration: NSTimeInterval(0.5))
            scaleAction.timingMode = .EaseOut
            
            let fadeInAction = SKAction.fadeAlphaTo(1.0, duration: 0.5)
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
                sprite.zPosition = 10
                
                var xplode = newSpark()
                xplode.position = pointForColumn(block.column, row: block.row)
                xplode.name = "spark"
                xplode.targetNode = self.scene
                xplode.zPosition = 100
                
                self.addChild(xplode)
                xplode.runAction(
                    SKAction.sequence(  [
                            SKAction.fadeOutWithDuration(NSTimeInterval(0.5)),
                            SKAction.removeFromParent()
                        ]
                    )
                )
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

