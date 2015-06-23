//
//  Global.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 5/12/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//
import Foundation

class Core {
    var name:String
    let data = DataManager()
    
    init(name:String) {
        self.name = name
    }
    
    final func randomInt(range:Int) -> Int {
        return Int(arc4random_uniform(UInt32(range)))
    }
}
var core = Core(name:"Awesome Global Class")

