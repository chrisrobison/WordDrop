import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, Printable {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    // #1
    static func rotate(orientation:Orientation, clockwise: Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
}

// The number of total shape varieties
let NumShapeTypes: UInt32 = 9
// let Level = TheWordDrop.getLevel()

// Shape indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, Printable {
    // The color of the shape
    let color:BlockColor
    
    // The blocks comprising the shape
    var blocks = Array<Block>()
    // The current orientation of the shape
    var orientation: Orientation
    // The column and row representing the shape's anchor point
    var column, row:Int
    var start, preview:Int
    var id:String
    
    // Required Overrides
    // #1
    // Subclasses must override this property
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    // #2
    // Subclasses must override this property
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    // #3
    var bottomBlocks:Array<Block> {
        if let bottomBlocks = bottomBlocksForOrientations[orientation] {
            return bottomBlocks
        }
        return []
    }
    
    // Hashable
    var hashValue:Int {
        // #4
        return reduce(blocks, 0) { $0.hashValue ^ $1.hashValue }
    }
    
    // Printable
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row:Int, color: BlockColor, orientation:Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        self.preview = PreviewColumn
        self.start = column
        self.id = NSUUID().UUIDString

        initializeBlocks()
    }
    
    convenience init(column:Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
    final func initializeBlocks() {
        // #2
        if let blockRowColumnTranslations = blockRowColumnPositions[orientation] {
            for i in 0..<blockRowColumnTranslations.count {
                let blockRow = row + blockRowColumnTranslations[i].rowDiff
                let blockColumn = column + blockRowColumnTranslations[i].columnDiff
                let newBlock = Block(column: blockColumn, row: blockRow, color: BlockColor.random())
                blocks.append(newBlock)
            }
        }
    }
    
    final func repositionBlocks(column:Int, row:Int) {
        if let blockRowColumnTranslations = blockRowColumnPositions[orientation] {
            for i in 0..<blockRowColumnTranslations.count {
                let blockRow = row + blockRowColumnTranslations[i].rowDiff
                let blockColumn = column + blockRowColumnTranslations[i].columnDiff
                blocks[i].row = blockRow
                blocks[i].column = blockColumn
            }
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        if let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] {
            // #1
            for (idx, element: (columnDiff:Int, rowDiff:Int)) in enumerate(blockRowColumnTranslation) {
                blocks[idx].column = column + element.columnDiff
                blocks[idx].row = row + element.rowDiff
            }
        }
    }
    
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: true)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: false)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }

    final func lowerShapeByOneRow() {
        shiftBy(0, rows:1)
    }

    final func raiseShapeByOneRow() {
        shiftBy(0, rows:-1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(1, rows:0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(-1, rows:0)
    }
    
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    final func moveTo(column: Int, row:Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }
    
    final class func random(startingColumn:Int, startingRow:Int, level:UInt32) -> Shape {
        var tmpskill = core.data.prefs["skill"] as! Int
        var skill = UInt32(tmpskill)
        //println("Skill: \(skill)")
        var cnt: UInt32 = level + (skill * 1) < NumShapeTypes ? level + skill : NumShapeTypes
        
        var startColumn = Int(arc4random_uniform(UInt32(NumColumns - 2))) + 1
         // cnt = 9
        var list = [UInt32](),
            mult = tmpskill
        
        for (var i=cnt; i>0; i--) {
            for x in 0...mult {
                list.append(i)
            }
            mult *= (1 / tmpskill) * 4
        }
        
        var pad = Array(count: mult + (20 / tmpskill), repeatedValue: UInt32(0))
        list += pad
            
        //println("list: \(list)")
        var p = Int(arc4random_uniform(UInt32(list.count)))
        var pick = Int(list[p])
//        switch Int(arc4random_uniform(cnt)) {
        switch pick {
        case 0:
            return SingleShape(column:startColumn, row:startingRow)
        case 1:
            return DoubleShape(column:startColumn, row:startingRow)
        case 2:
            return TripleShape(column:startColumn, row:startingRow)
        case 3:
            return LineShape(column:startColumn, row:startingRow)
        case 4:
            return TShape(column:startColumn, row:startingRow)
        case 5:
            return JShape(column:startColumn, row:startingRow)
        case 6:
            return LShape(column:startColumn, row:startingRow)
        case 7:
            return SShape(column:startColumn, row:startingRow)
        case 8:
            return SquareShape(column:startColumn, row:startingRow)
        case 9:
            return ZShape(column:startColumn, row:startingRow)
        default:
            return SingleShape(column:startColumn, row:startingRow)
        }
    }
}

func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}
