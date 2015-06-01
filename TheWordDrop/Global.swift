//
//  Global.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 5/12/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

class Core {
    var name:String
    let data = DataManager()
    
    init(name:String) {
        self.name = name
    }
}
var core = Core(name:"My Global Class")

