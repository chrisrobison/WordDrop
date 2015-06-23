class SShape:Shape {
    /*
    
    Orientation 0
    
    |   |   |   |
    |   | 0 | 1 |
    | 2 | 3 |   |
    |   |   |   |
    
    Orientation 90
    
    | 2 |   |   |
    | 3 | 0 |   |
    |   | 1 |   |
    |   |   |   |
    
    Orientation 180
    
    |   | 2 | 3 |
    | 1 | 0 |   |
    |   |   |   |
    |   |   |   |
    
    
    Orientation 270
    
    |   | 1 |   |
    |   | 0 | 2 |
    |   |   | 3 |
    |   |   |   |
    
    
    • marks the row/column indicator for the shape
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [( 0, 0), ( 1, 0), (-1, 1), ( 0, 1)],
            Orientation.Ninety:     [( 0, 0), ( 0, 1), (-1,-1), (-1, 0)],
            Orientation.OneEighty:  [( 0, 0), (-1, 0), ( 0,-1), ( 1,-1)],
            Orientation.TwoSeventy: [( 0, 0), ( 0,-1), ( 1, 0), ( 1, 1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[FirstBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}