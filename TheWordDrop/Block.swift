
import SpriteKit

let NumberOfColors: UInt32 = 7

enum BlockColor: Int, Printable {
    
    case Grey = 0, Blue, Orange, Purple, Red, Teal, Yellow
    
    var spriteName: String {
        switch self {
        // Grey:            X - no bonuses
        case .Grey:
            return "grey"
        // Blue:            2L - Double letter value
        case .Blue:
            return "blue"
        // Orange:          3L - Triple letter value
        case .Orange:
            return "orange"
        // Purple:          4L - Quadruple letter value
        case .Purple:
            return "purple"
        // Red:             2W - Double word value
        case .Red:
            return "red"
        // Teal             3W - Triple word value
        case .Teal:
            return "cyan"
        // Yellow           4W - Quadruple word value
        case .Yellow:
            return "yellow"
        }
    }
    
    var spriteColor: UIColor {
        switch self {
            // Grey:            X - no bonuses
        case .Grey:
            return UIColor.lightGrayColor()
            // Blue:            2L - Double letter value
        case .Blue:
            return UIColor.blueColor()
            // Orange:          3L - Triple letter value
        case .Orange:
            return UIColor.orangeColor()
            // Purple:          4L - Quadruple letter value
        case .Purple:
            return UIColor.purpleColor()
            // Red:             2W - Double word value
        case .Red:
            return UIColor.redColor()
            // Teal             3W - Triple word value
        case .Teal:
            return UIColor.cyanColor()
            // Yellow           4W - Quadruple word value
        case .Yellow:
            return UIColor.yellowColor()
        }
    }

    var description: String {
        return self.spriteName
    }
    
    static func random() -> BlockColor {
        // 80% of the time, give a normal, grey (0) tile
        // 20% of the time, assign a random color
        var x = Int(arc4random_uniform(10))
        if (x > 8) {
            return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
        } else {
            return BlockColor(rawValue: 0)!
        }
    }
}

class Block: Hashable, Printable {
    // Constants
    let color: BlockColor
    
    // Properties
    var column: Int
    var row: Int
    var letter: String
    var sprite: SKShapeNode?
    var spriteColor: UIColor {
            return color.spriteColor
    }
    var id:String
    
    var spriteName: String {
        return color.spriteName
    }
    
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    var description: String {
        return "\(letter): [\(column), \(row)]"
    }
    
    var textureCache = Dictionary<String, SKTexture>()

    init(column:Int, row:Int, color:BlockColor, letter:String) {
        self.column = column
        self.row = row
        self.color = color
        self.letter = letter
        self.id = NSUUID().UUIDString
        core.data.totalTiles++
    }
    
    convenience init(column:Int, row:Int, color:BlockColor) {
        var letter = core.data.getLetter()
        self.init(column: column, row:row, color:color, letter:letter)
    }

    convenience init(column:Int, row:Int, letter:String) {
        var letter = letter
        var color:BlockColor
        
        if (letter == "💣") {
            color = BlockColor.Blue
        } else {
            color = BlockColor.random()
        }
        
        self.init(column: column, row:row, color:color, letter:letter)
    }
    
    convenience init(column:Int, row:Int) {
        var letter = core.data.getLetter()
        var color:BlockColor
        
        if (letter == "💣") {
            color = BlockColor.Blue
        } else {
            color = BlockColor.random()
        }
        
        self.init(column:column, row:row, color:color, letter:letter)
    }
}

func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}