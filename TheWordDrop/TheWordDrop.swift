 import AVFoundation
 
 let NumColumns = 8
 let NumRows = 18
 
 let StartingColumn = 4
 let StartingRow = 1
 
 let PreviewColumn = 8
 let PreviewRow = 4
 
 let PointsPerLine = 10
 let LevelThreshold = 100

 protocol TheWordDropDelegate {
    // Invoked when the current round of TheWordDrop ends
    func gameDidEnd(theworddrop: TheWordDrop)
    
    // Invoked immediately after a new game has begun
    func gameDidBegin(theworddrop: TheWordDrop)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(theworddrop: TheWordDrop)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(theworddrop: TheWordDrop)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(theworddrop: TheWordDrop)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(theworddrop: TheWordDrop)
    
 }
 
 class TheWordDrop {
    let dataManager = DataManager()
    let synth = AVSpeechSynthesizer()

    var delegate:TheWordDropDelegate?

    var blockArray:Array2D<Block>,
        shapeQueue:Array<Shape> = [],
        nextShape:Shape?,
        fallingShape:Shape?
    
    var score:Int,
        level:UInt32,
        lastWord:String,
        lastPoint:Int,
        lastWords:Array<String> = [],
        myUtterance:AVSpeechUtterance?
    
    init() {
        score = 0
        level = 1
        lastWord = ""
        lastPoint = 0
        
        fallingShape = nil
        nextShape = nil
        
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
        var points = 0, val = 0, bonus:Int = 0, word = "", out = "", wordBonuses = [Int]()
        
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
                wordBonuses.append(2)
                bonus += 2
            case .Teal:         // 3W
                wordBonuses.append(3)
                bonus += 3
            case .Yellow:       // 4W
                wordBonuses.append(4)
                bonus += 4
            case .Grey:         // No bonus
                val = val + 0
            }
            
            points += val
            word += tile.letter
        }
        
        if bonus > 0 {
            points = points * bonus
        }
        
        out = "\(word) +\(points)"
        
        lastWords.append(out)

        return points
    }
    
    func removeCompletedWords() -> (tilesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedTiles = Array<Array<Block>>(),
            tiles = Array<Block>(),
            points = 0,
            fallenBlocks = Array<Array<Block>>(),
            queuedBlocks:[(String,Int,Array<Block>)] = [],
            foundWords:[String],
        colsOfBlocks = Array<Array<Block?>>(count:NumRows, repeatedValue: Array<Block?>()),
            colStrings = Array<String>(count: NumColumns, repeatedValue:"")

        for var row = NumRows - 1; row > 0; row-- {
            var rowOfBlocks = Array<Block?>(),
                rowString = "",
                haveTiles = false
            
            // Get blocks for row
            for column in 0..<NumColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                    colsOfBlocks[column].insert(block, atIndex:0)
                    colStrings[column] = block.letter + colStrings[column]
                    rowString += block.letter
                    haveTiles = true
                } else {
                    rowOfBlocks.append(nil)
                    rowString += " "
                    colsOfBlocks[column].insert(nil, atIndex:0)
                    colStrings[column] = " " + colStrings[column]
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
                    
                    sayWord(foundWords[0])
                }
            }
        }

        // Now check for vertical words
        for column in 0..<NumColumns {
            var colOfBlocks = colsOfBlocks[column],
                colString = colStrings[column]
            
            /*
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
            */
            
            (foundWords, tiles) = dataManager.findWords(colString, blocks: colOfBlocks)
            
            if foundWords.count > 0 {
                removedTiles.append(tiles)
                lastPoint = calculatePoints(tiles)
                score += lastPoint
                    
                let tup = (foundWords[0], lastPoint, tiles)
                
                queuedBlocks.append(tup)
                
                sayWord(foundWords[0])
            }
        }

        if removedTiles.count == 0 {
            return ([], [])
        }
        
        if core.data.level != Int(self.level) {
            self.level = UInt32(core.data.level)
            delegate?.gameDidLevelUp(self)
        }
        
        core.data.queuedBlocks += queuedBlocks
        
        for tileQueue in removedTiles {
            for tile in tileQueue {
                blockArray[tile.column, tile.row] = nil
            }
        
        
            for tile in tileQueue {
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
        }
        
        // removedTiles.append(tiles)
        var cols = [String]()
        var fallenBlocksArray = Array<Block>()
        var floating = false
        
        // Check for blocks hanging without support
        for column in 0..<NumColumns {
            for var row = NumRows - 2; row > 0; row-- {
                floating = false
                // Check if we have a block with no block below it
                if blockArray[column, row] != nil && blockArray[column, row + 1] == nil {
                    // check for anchors in next row
                    if (
                            (column==0 || blockArray[column-1,row+1]==nil) && (column==NumColumns-1 || blockArray[column+1,row+1]==nil)) || ((column==0 || blockArray[column-1,row]==nil) && (column==NumColumns-1 || blockArray[column+1,row]==nil)) {
                        floating = true
                    }
                }
                
                if floating == true {
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
    
    func clearFloatingBlocks() {
        
    }
    
    func sayWord(word:String) {
        myUtterance = AVSpeechUtterance(string: word)
        myUtterance!.rate = 0.3
        synth.speakUtterance(myUtterance)
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
