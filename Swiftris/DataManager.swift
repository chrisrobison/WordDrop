//
//  DataManager.swift
//  JSON Dictionary classes and handlers
//
//  Created by Christopher Robison on 4/29/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import Foundation

let LetterValues: Dictionary<String, Int> = [    "A": 1, "B": 3, "C": 3, "D": 2, "E": 1,
    "F": 4, "G": 2, "H": 4, "I": 1, "J": 8,
    "K": 5, "L": 1, "M": 3, "N": 1, "O": 1,
    "P": 3, "Q": 10, "R": 1, "S": 1, "T": 1,
    "U": 1, "V": 4, "W": 4, "X": 8, "Y": 4, "Z": 10 ]


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
    
    func findWords(var myletters:String, blocks:Array<Block?>) -> ([String], Array<Block>) {
        var found = [String]()
        var length = count(myletters)
        var myblocks = blocks
        var letters = myletters
        
//        while myblocks.count > shortestWord {
        while count(myletters) > shortestWord {
            // =========DEBUG========= //
            //  letters = "".join(myblocks.map({"\($0.letter)"}))
            // println("Looking for words in \(letters)")
            // length = myblocks.count
            
            // println("Checking \(myletters) for words")
            
            for index in shortestWord...length {
                var gotone = checkWord(myletters.substringToIndex(advance(myletters.startIndex, index)))
                if gotone != "" {
                    found.append(gotone)
                }
            }
            // myblocks.removeAtIndex(0)
            
            myletters = myletters.substringFromIndex(advance(myletters.startIndex, 1))
            length = count(myletters)
        }
        
        if found.count < 1 {
            println("Found no words in '\(letters)'")
            return([], [])
        }
        // =========DEBUG========= //
        println("Found \(found.count) words: \(found)")

        var longest = ""
        for word in found {
            if count(word) > count(longest) {
                longest = word
            }
        }
        var tiles:Array<Block> = []
        
        if let range = letters.rangeOfString(longest) {
            let index = distance(letters.startIndex, range.startIndex)
            
            for i in index...(index + count(longest) - 1) {
                tiles.append(blocks[i]!)
            }
        }

        return ([longest], tiles)
        
    }
    
    func checkWord(word:String) -> String {
        var subjson = json,
        myword = "", letter:String,
        lastword = ""
        
        var letters = Array(word + "$")
        // println("checkWord: looking for: \(letters)")
        
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