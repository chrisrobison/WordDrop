 let NumColumns = 10
 let NumRows = 17
 
 let StartingColumn = 5
 let StartingRow = 2
 
 let PreviewColumn = 5
 let PreviewRow = 0
 
 let PointsPerLine = 10
 let LevelThreshold = 250

 protocol SwiftrisDelegate {
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    // Invoked immediately after a new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
    
 }
 
 class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    var score:Int
    var level:UInt32
    var shapeQueue:Array<Shape> = []
    let dataManager = DataManager()
    
    init() {
        score = 0
        level = 1
        
        fallingShape = nil
        nextShape = nil
        
        /*
        var tmpshape:Shape?
        
        for (var i=0; i < NumColumns; i++) {
            tmpshape = Shape.random(i, startingRow: PreviewRow, level: level)
            tmpshape?.moveTo(i, row: 0)
            shapeQueue.append(tmpshape!)
        }
        */
        
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow, level: level)
        }
        delegate?.gameDidBegin(self)
    }
    
    func getLevel() -> UInt32 {
        return self.level
    }
    
    // #2
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow, level: level)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        if detectIllegalPlacement() {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        if let shape = fallingShape {
            for block in shape.blocks {
                if block.column < 0 || block.column >= NumColumns
                    || block.row < 0 || block.row >= NumRows {
                        println("Detected illegal block placement [OUT OF BOUNDS]: (\(block.row),\(block.column))")
                        return true
                } else if blockArray[block.column, block.row] != nil {
                    println("Detected illegal block placement [SPACE OCCUPIED]: (\(block.row),\(block.column) - \(blockArray[block.column,block.row]))")
                    return true
                }
            }
        }
        return false
    }
    
    func settleShape() {
        if let shape = fallingShape {
            for block in shape.blocks {
                blockArray[block.column, block.row] = block
            }
            fallingShape = nil
            delegate?.gameShapeDidLand(self)
        }
    }
    
    // #2
    func detectTouch() -> Bool {
        if let shape = fallingShape {
            for bottomBlock in shape.bottomBlocks {
                if bottomBlock.row == NumRows - 1 ||
                    blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                        return true
                }
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    func removeCompletedWords() -> (tilesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        var removedTiles = Array<Array<Block>>()
        var tiles = Array<Block>()
        var points = 0
        
        for var row = NumRows - 1; row > 0; row-- {
            var rowOfBlocks = Array<Block?>()
            var rowString = ""
            var foundWords:[String]
            var haveTiles = false
            
            // Get blocks for row
            for column in 0..<NumColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                    rowString += block.letter
                    haveTiles = true
                } else {
                    rowOfBlocks.append(nil)
                    rowString += " "
                }
            }
            
            if (haveTiles) {
                // Find any words in row aan
                (foundWords, tiles) = dataManager.findWords(rowString, blocks: rowOfBlocks)
            
                if foundWords.count > 0 {
                    // Move blocks into removedTiles array
                    println(foundWords)
                    removedTiles.append(tiles)
                    for tile in tiles {
                        points += LetterValues[tile.letter]!
                        blockArray[tile.column, tile.row] = nil
                    }
                
                }
            }
        }
        
        // #3
        if removedTiles.count == 0 {
            return ([], [])
        }
        // #4
        let pointsEarned = points * Int(level)
        score += pointsEarned
        if score >= Int(level) * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for tile in removedTiles[0] {
            var column = tile.column
            
            var fallenBlocksArray = Array<Block>()
            // #5
            for var row = tile.row - 1; row > 0; row-- {
                if let block = blockArray[column, row] {
                    var newRow = row
                    while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                        newRow++
                    }
                    block.row = newRow
                    blockArray[column, row] = nil
                    blockArray[column, newRow] = block
                    fallenBlocksArray.append(block)
                }
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        
        removedTiles.append(tiles)
        return (removedTiles, fallenBlocks)
    }
    
    func dropShape() {
        if let shape = fallingShape {
            while detectIllegalPlacement() == false {
                shape.lowerShapeByOneRow()
            }
            shape.raiseShapeByOneRow()
            delegate?.gameShapeDidDrop(self)
        }
    }
    
    // #2
    func letShapeFall() {
        if let shape = fallingShape {
            shape.lowerShapeByOneRow()
            if detectIllegalPlacement() {
                shape.raiseShapeByOneRow()
                if detectIllegalPlacement() {
                    endGame()
                } else {
                    settleShape()
                }
            } else {
                delegate?.gameShapeDidMove(self)
                if detectTouch() {
                    settleShape()
                }
            }
        }
    }
    
    // #3
    func rotateShape() {
        if let shape = fallingShape {
            shape.rotateClockwise()
            if detectIllegalPlacement() {
                shape.rotateCounterClockwise()
            } else {
                delegate?.gameShapeDidMove(self)
            }
        }
    }
    
    // #4
    func moveShapeLeft() {
        if let shape = fallingShape {
            shape.shiftLeftByOneColumn()
            if detectIllegalPlacement() {
                shape.shiftRightByOneColumn()
                return
            }
            delegate?.gameShapeDidMove(self)
        }
    }
    
    func moveShapeRight() {
        if let shape = fallingShape {
            shape.shiftRightByOneColumn()
            if detectIllegalPlacement() {
                shape.shiftLeftByOneColumn()
                return
            }
            delegate?.gameShapeDidMove(self)
        }
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                    blockArray[column, row] = nil
                }
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
 }