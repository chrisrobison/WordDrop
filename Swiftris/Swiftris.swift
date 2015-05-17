 let NumColumns = 10
 let NumRows = 18
 
 let StartingColumn = 4
 let StartingRow = 2
 
 let PreviewColumn = 4
 let PreviewRow = 1
 
 let PointsPerLine = 10
 let LevelThreshold = 100

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
    var lastWord:String
    var lastPoint:Int
    var lastWords:Array<String> = []
    
    init() {
        score = 0
        level = 1
        lastWord = ""
        lastPoint = 0
        
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
                        //println("Detected illegal block placement [OUT OF BOUNDS]: (\(block.row),\(block.column))")
                        return true
                } else if blockArray[block.column, block.row] != nil {
                        //println("Detected illegal block placement [SPACE OCCUPIED]: (\(block.row),\(block.column) - \(blockArray[block.column,block.row]))")
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
        core.data.level = 1
        
        delegate?.gameDidEnd(self)
    }

   /* Calculate points for a word including special bonus tiles
    * Bonus values are based on the tile color and are as follows:
    *
    * Blue: 2L  Orange: 3L  Purple: 4L
    * Red:  2W  Teal:   3W  Yellow: 4W
    *
    */
    final func calculatePoints(tiles:Array<Block>) -> Int {
        var points = 0, val = 0, wordMultipiers:[Int] = [], word = ""
        
        for tile in tiles {
            var val = LetterValues[tile.letter]!
            
            switch tile.color {
            case .Blue:         // 2L
                val = val * 2
            case .Orange:       // 3L
                val = val * 3
            case .Purple:       // 4L
                val = val * 4
            case .Red:          // 2W
                wordMultipiers.append(2)
            case .Teal:         // 3W
                wordMultipiers.append(3)
            case .Yellow:       // 4W
                wordMultipiers.append(4)
            case .Grey:         // No bonus
                val = val + 0
            }
            
            points += val
            word += tile.letter
        }
        
        var out = "\(word) +\(points)"
        
        // Loop over any word multipliers and apply bonus
        for bonus in wordMultipiers {
            out = out + "x\(bonus)W"
            points = points * bonus
        }
        
        lastWords.append(out)

        return points
    }
    
    func removeCompletedWords() -> (tilesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedTiles = Array<Array<Block>>(),
            tiles = Array<Block>(),
            points = 0,
            fallenBlocks = Array<Array<Block>>(),
            queuedBlocks:[(String,Int,Array<Block>)] = [],
            foundWords:[String]

        for var row = NumRows - 1; row > 0; row-- {
            var rowOfBlocks = Array<Block?>(),
                rowString = "",
                haveTiles = false
            
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
            
            // Check for words, calculate points when found
            if (haveTiles) {
                (foundWords, tiles) = dataManager.findWords(rowString, blocks: rowOfBlocks)

                if foundWords.count > 0 {
                    removedTiles.append(tiles)
                    lastPoint = calculatePoints(tiles)
                    score += lastPoint

                    let tup = (foundWords[0], lastPoint, tiles)
                    
                    queuedBlocks.append(tup)
                }
            }
        }
        
        // Now check for vertical words
        for column in 0..<NumColumns {
            var colOfBlocks = Array<Block?>(),
                colString = "",
                haveTiles = false
            
            // Get blocks for column
            for row in 0..<NumRows {
                if let block = blockArray[column, row] {
                    colOfBlocks.append(block)
                    colString += block.letter
                    haveTiles = true
                } else {
                    colOfBlocks.append(nil)
                    colString += " "
                }
            }
            
            if (haveTiles) {
                (foundWords, tiles) = dataManager.findWords(colString, blocks: colOfBlocks)
                
                if foundWords.count > 0 {
                    removedTiles.append(tiles)
                    lastPoint = calculatePoints(tiles)
                    score += lastPoint
                    
                    let tup = (foundWords[0], lastPoint, tiles)
                    
                    queuedBlocks.append(tup)
                }
            }
        }

        // #3
        if removedTiles.count == 0 {
            return ([], [])
        }
        
        if core.data.level != Int(self.level) {
            self.level = UInt32(core.data.level)
            delegate?.gameDidLevelUp(self)
        }
        
        core.data.queuedBlocks += queuedBlocks
        
        for tile in removedTiles[0] {
            blockArray[tile.column, tile.row] = nil
        }
        
        for tile in removedTiles[0] {
            var fallenBlocksArray:Array<Block> = []
            
            for var row = tile.row - 1; row > 0; row-- {
                if let block = blockArray[tile.column, row] {
                    var newRow = row
                    while (newRow < NumRows - 1 && blockArray[tile.column, newRow + 1] == nil) {
                        newRow++
                    }
                    block.row = newRow
                    blockArray[tile.column, row] = nil
                    blockArray[tile.column, newRow] = block
                    fallenBlocksArray.append(block)
                }
            }
            fallenBlocks.append(fallenBlocksArray)
        }
        
        // removedTiles.append(tiles)
        var cols = [String]()
        var fallenBlocksArray = Array<Block>()
        
        // Check for blocks hanging without support
        for column in 0..<NumColumns - 1 {
            for var row = NumRows - 2; row > 0; row-- {
                if blockArray[column, row] != nil &&    // have block?
                    (column==0 || blockArray[column - 1, row] == nil) &&    // is slot to left empty?
                    (column==NumColumns-1 || blockArray[column + 1, row] == nil) &&   // is slot to right empty?
                    blockArray[column, row + 1] == nil      // and is slot below empty
                    {
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
                        if fallenBlocksArray.count > 0 {
                            fallenBlocks.append(fallenBlocksArray)
                    }
                }
            }
        }
        core.data.queuedBlocks = queuedBlocks
        
        fallingShape = nil
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