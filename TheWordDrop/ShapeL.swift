class LShape:Shape {
    /*
    
     -1   0   1
    Orientation 0
-1  |   | 0 |   |
 0  |   | 1•|   |
 1  |   | 2 | 3 |
    |   |   |   |
    
    Orientation 90
    |   |   |   |
    | 2 | 1•| 0 |
    | 3 |   |   |
    |   |   |   |
    
    Orientation 180
    | 3 | 2 |   |
    |   | 1•|   |
    |   | 0 |   |
    |   |   |   |
    
    Orientation 270
    |   |   | 3 |
    | 0 | 1•| 2 |
    |   |   |   |
    |   |   |   |
    
    • marks the row/column indicator for the shape
    
    Pivots about `1`
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [ ( 0,-1), ( 0, 0),  ( 1, 0), ( 1, 1)],
            Orientation.Ninety:     [ ( 1, 0), ( 0, 0),  (-1, 0), (-1, 1)],
            Orientation.OneEighty:  [ ( 0, 1), ( 0, 0),  ( 0,-1), (-1,-1)],
            Orientation.TwoSeventy: [ (-1, 0), ( 0, 0),  ( 1, 0), ( 1,-1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[FirstBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[ThirdBlockIdx]]
        ]
    }
}