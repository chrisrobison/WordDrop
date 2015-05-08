class TripleShape:Shape {
    /*
    
    Orientation 0
    
    | 0 |
    | 1•| 2 |
    
    Orientation 90
    
    
    |•1 | 0 |
    | 2 |
    
    Orientation 180
    
    | 2 | 1•|
        | 0 |
    
    Orientation 270
    
        | 2•|
    | 0 | 1 |
    
    • marks the row/column indicator for the shape
    
    Pivots about `1`
    
    */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [ (0, -1), (0, 0),  (1, 0) ],
            Orientation.Ninety:     [ (1, 0), (0, 0),  (0, 1) ],
            Orientation.OneEighty:  [ (0, 1), (0, 0),  (-1, 0) ],
            Orientation.TwoSeventy: [ (-1, 0), (0, 0),  (0, -1) ]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[SecondBlockIdx], blocks[ThirdBlockIdx]],
            Orientation.Ninety:     [blocks[SecondBlockIdx], blocks[FirstBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FirstBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[SecondBlockIdx]]
        ]
    }
}