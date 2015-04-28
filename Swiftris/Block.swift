import SpriteKit

// #1
let NumberOfColors: UInt32 = 6

// #2
enum BlockColor: Int, Printable {
    
    // #3
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    // #4
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
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
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
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
        self.letter = randomStringWithLength(1)
    }
    

}

func randomStringWithLength (len : Int) -> String {
    
    let letters : NSString = "AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZAAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ"
    
    var randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        var length = UInt32 (letters.length)
        var rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString as String
}

let uppercaseLetters = Array(65...90).map {String(UnicodeScalar($0))}
func randomLetter() -> String {
    let randomIndex = arc4random_uniform(UInt32(uppercaseLetters.count))
    return uppercaseLetters[Int(randomIndex)]
}

// #7
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}