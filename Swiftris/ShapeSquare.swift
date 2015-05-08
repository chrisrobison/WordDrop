class SquareShape:Shape {
    /*
    // #1
    
    Orientation 0:
    
        | 0•| 1 |
        | 2 | 3 |
    
    Orientation 90:
    
        | 2 | 0•|
        | 3 | 1 |
    
    Orientation 180:
    
        | 3 | 2 |
        | 1 | 0 |
    
    Orientation 270:
    
        | 1 | 3 |
        | 0 | 2 |
    
    • marks the row/column indicator for the shape
    
    */
    
    // The square shape will not rotate
    
    // #2
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(0, 0),(1, 0),(0, 1),(1, 1)],
            Orientation.OneEighty:  [(1, 1),(0, 1),(1, 0),(0, 0)],
            Orientation.Ninety:     [(1, 0),(1, 1),(0, 0),(0, 1)],
            Orientation.TwoSeventy: [(0, 1),(0, 0),(1, 1),(0, 0)]
        ]
    }
    
    // #3
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}