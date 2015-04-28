class DoubleShape:Shape {
    /*
    Orientations 0 and 180:
    
        | 0•|
        | 1 |
    
    Orientations 90:
    
    | 1 | 0•|
    
    Orientations 180:
    
        | 1•|
        | 0 |
    
    Orientations 270:
    
        | 0 | 1•|
    
    • marks the row/column indicator for the shape
    
    */
    
    // Hinges about the first block
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(0, 0), (0, 1)],
            Orientation.Ninety:     [(0, 0), (-1, 0)],
            Orientation.OneEighty:  [(0, 0), (0, -1)],
            Orientation.TwoSeventy: [(0, 0), (1, 0)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[SecondBlockIdx]],
            Orientation.Ninety:     blocks,
            Orientation.OneEighty:  [blocks[SecondBlockIdx]],
            Orientation.TwoSeventy: blocks
        ]
    }
}