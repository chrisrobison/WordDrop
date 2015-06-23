class ZShape:Shape {
    /*
    
    Orientation 0
    
    |   |   |   |
    | 0 | 1 |   |
    |   | 2 | 3 |
    |   |   |   |
    
    Orientation 90
    
    |   | 0 |   |
    | 2 | 1 |   |
    | 3 |   |   |
    |   |   |   |
    
    Orientation 180
    
    |   |   |   |
    | 3 | 2 |   |
    |   | 1 | 0 |
    |   |   |   |
    
    
    Orientation 270
    
    |   |   | 3 |
    |   | 1 | 2 |
    |   | 0 |   |
    |   |   |   |
    
    
    • marks the row/column indicator for the shape
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(-1, 0), (0, 0), ( 0, 1), ( 1, 1)],
            Orientation.Ninety:     [( 0,-1), (0, 0), (-1, 0), (-1, 1)],
            Orientation.OneEighty:  [( 1, 0), (0, 0), ( 0,-1), (-1,-1)],
            Orientation.TwoSeventy: [( 0, 1), (0, 0), ( 1,-1), ( 1,-1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[FirstBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}