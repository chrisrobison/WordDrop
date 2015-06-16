class LineShape:Shape {
    /*
    Orientations 0:
    
        | 0 |
        | 1•|
        | 2 |

    
    Orientations 90:
    
    | 2 | 1•| 0 |
    

    Orientations 180:
    
        | 2 |
        | 1•|
        | 0 |
    

    Orientations 270:
    
    | 0 | 1•| 2 |
    
    • marks the row/column indicator for the shape
    
    */
    
    // Hinges about the second block
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [( 0,-1), (0,0), (0, 1)],
            Orientation.Ninety:     [( 1, 0), (0,0), (-1, 0)],
            Orientation.OneEighty:  [( 0, 1), (0,0), (0, -1)],
            Orientation.TwoSeventy: [(-1, 0), (0,0), (1, 0)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx]],
            Orientation.Ninety:     blocks,
            Orientation.OneEighty:  [blocks[ThirdBlockIdx]],
            Orientation.TwoSeventy: blocks
        ]
    }
}