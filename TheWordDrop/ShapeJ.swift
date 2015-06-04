class JShape:Shape {
    /*
    
    Orientation 0
    |   | 0 |   |
    |   | 1•|   |
    | 3 | 2 |   |
    
    Orientation 90
    | 3 |   |   |
    | 2 | 1•| 0 |
    |   |   |   |
    
    Orientation 180
    |   | 2 | 3 |
    |   | 1•|   |
    |   | 0 |   |
    
    Orientation 270
    |   |   |   |
    | 0 | 1•| 2 |
    |   |   | 3 |
    
    • marks the row/column indicator for the shape
    
    Pivots about `1`
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [ ( 0,-1), ( 0, 0),  ( 0, 1), (-1, 1)],
            Orientation.Ninety:     [ ( 1, 0), ( 0, 0),  (-1, 0), (-1,-1)],
            Orientation.OneEighty:  [ ( 0, 1), ( 0, 0),  ( 0,-1), ( 1,-1)],
            Orientation.TwoSeventy: [ (-1, 0), ( 0, 0),  ( 1, 0), ( 1, 1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[ThirdBlockIdx]],
            Orientation.OneEighty:  [blocks[FirstBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}