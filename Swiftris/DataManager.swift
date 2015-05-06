//
//  DataManager.swift
//  JSON Dictionary classes and handlers
//
//  Created by Christopher Robison on 4/29/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import Foundation

class DataManager {
    var loaded:Bool
    var json:JSON
    let shortestWord:Int = 3
    
    func getWordsFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        //1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //2
            let filePath = NSBundle.mainBundle().pathForResource("all",ofType:"json")
            
            var readError:NSError?
            if let data = NSData(contentsOfFile:filePath!,
                options: NSDataReadingOptions.DataReadingUncached,
                error:&readError) {
                    self.loaded = true
                    success(data: data)
            }
        })
    }
    
    func findWord(var myletters:String) -> [String] {
        var found = [String]()
        var length = count(myletters)
        
        while count(myletters) > shortestWord {
            // println("Checking \(myletters) for words")
            for index in shortestWord...length {
                var gotone = checkWord(myletters.substringToIndex(advance(myletters.startIndex, index)))
                if gotone != "" {
                    found.append(gotone)
                }
            }
            myletters = myletters.substringFromIndex(advance(myletters.startIndex, 1))
            length = count(myletters)
        }
        
        // println("Found \(found.count) words: \(found)")
        
        return found
        
    }
    
    func checkWord(word:String) -> String {
        var subjson = json,
        myword = "", letter:String,
        lastword = ""
        
        var letters = Array(word + "$")
        
        for char in letters {
            letter = String(char)
            var found = subjson[letter]
            
            if (found != nil) {
                if letter == "$" {
                    lastword = myword
                    //                    println("\(word) is VALID")
                } else {
                    myword += letter
                    
                    //                    println("Found \(letter) (so far \(myword) of \(word))")
                    subjson = subjson[letter]
                }
            } else {
                return ""
            }
        }
        
        return lastword
    }
    
    init() {
        self.loaded = false
        
        var path     = NSBundle.mainBundle().pathForResource("all", ofType: "json"),
        url      = NSURL(fileURLWithPath: path!),
        data     = NSData(contentsOfURL: url!),
        content = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as? [[String: AnyObject]]
        
        
        self.json = JSON(data: data!)
        
        self.loaded = true
    }
    
}