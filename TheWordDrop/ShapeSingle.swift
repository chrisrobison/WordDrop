//
//  SingleShape.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 4/22/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

class SingleShape:Shape {
    /*
    Orientations 0 and 180:
    
    | 0•|
    
    Orientations 90 and 270:
    
    | 0•|
    
    • marks the row/column indicator for the shape
    
    */
    
    // Hinges about the second block
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(0, 0)],
            Orientation.Ninety:     [(0, 0)],
            Orientation.OneEighty:  [(0, 0)],
            Orientation.TwoSeventy: [(0, 0)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       blocks,
            Orientation.Ninety:     blocks,
            Orientation.OneEighty:  blocks,
            Orientation.TwoSeventy: blocks
        ]
    }
}