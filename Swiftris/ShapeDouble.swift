class DoubleShape:Shape {
    /*
    Orientations 0:
        |   | 1 |   |
        |   | 0•|   |
        |   |   |   |
    Orientations 90:
        |   |   |   |
        |   | 0•| 1 |
        |   |   |   |
    Orientations 180:
        |   |   |   |
        |   | 0•|   |
        |   | 1 |   |
    Orientations 270:
        |   |   |   |
        | 1 | 0•|   |
        |   |   |   |
    • marks the row/column indicator for the shape
    
    */
    
    // Hinges about the first block
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(1,1),(1,0)],
            Orientation.Ninety:     [(1,1),(2,1)],
            Orientation.OneEighty:  [(1,1),(1,2)],
            Orientation.TwoSeventy: [(1,1),(0,1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[FirstBlockIdx]],
            Orientation.Ninety:     blocks,
            Orientation.OneEighty:  [blocks[SecondBlockIdx]],
            Orientation.TwoSeventy: blocks
        ]
    }
    
}