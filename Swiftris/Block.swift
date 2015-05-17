import SpriteKit

// #1
let NumberOfColors: UInt32 = 7

// #2
enum BlockColor: Int, Printable {
    
    // #3
    case Grey = 0, Blue, Orange, Purple, Red, Teal, Yellow
    
    // #4
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
            return "teal"
        // Yellow           4W - Quadruple word value
        case .Yellow:
            return "yellow"
        }
    }
    
    // #5
    var description: String {
        return self.spriteName
    }
    
    // #6
    static func random() -> BlockColor {
        var x = Int(arc4random_uniform(10))
        if (x > 7) {
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
    var sprite: SKSpriteNode?
    
    var spriteName: String {
        return color.spriteName
    }
    
    // #5
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // #6
    var description: String {
        return "\(letter): [\(column), \(row)]"
    }
    
    var textureCache = Dictionary<String, SKTexture>()

    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
        self.letter = core.data.getLetter()
    }
}

// #7
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}