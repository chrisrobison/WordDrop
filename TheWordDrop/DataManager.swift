//
//  DataManager.swift
//  JSON Dictionary classes and handlers
//
//  Created by Christopher Robison on 4/29/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

let LetterValues: Dictionary<String, Int> = [
    "A": 1, "B": 3, "C": 3, "D": 2, "E": 1,
    "F": 4, "G": 2, "H": 4, "I": 1, "J": 8,
    "K": 5, "L": 1, "M": 3, "N": 1, "O": 1,
    "P": 3, "Q": 10, "R": 1, "S": 1, "T": 1,
    "U": 1, "V": 4, "W": 4, "X": 8, "Y": 4,
    "Z": 10, "💣": 10 ]

class DataManager {
    let shortestWord:Int = 3
    var json:JSON,
        letterQueue = Array<String>(),
        queuedBlocks:[(String,Int,Array<Block>)] = [],
        level:Int,
        settingsScene:SKScene?,
        BlockSize:CGFloat = 32.0,
        screenSize = 0.0,
        screenWidth:CGFloat = 0,
        screenHeight:CGFloat = 0,
        wordCache = [String: Int](),
        viewCache = [String: UIView](),
        wordsLabel:UILabel?,
        scoreLabel:UILabel?,
        lastWord:UILabel?,
        prefs = [String:AnyObject](),
        musicPlayer:AVAudioPlayer?,
        paused:Bool = false
    
    var bigrams = [ "TH","HE","IN","ER","AN","RE","ON","AT","EN","ND","TI",
                    "ES","OR","TE","OF","ED","IS","IT","AL","AR","ST","TO",
                    "NT","NG","SE","HA","AS","OU","IO","LE","VE","CO","ME",
                    "DE","HI","RI","RO","IC","NE","EA","RA","CE","LI","CH",
                    "LL","BE","MA","SI","OM","UR" ]
    
    func getWordsFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        //1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //2
            let filePath = NSBundle.mainBundle().pathForResource("all",ofType:"json")
            
            var readError:NSError?
            if let data = NSData(contentsOfFile:filePath!,
                options: NSDataReadingOptions.DataReadingUncached,
                error:&readError) {
                    success(data: data)
            }
        })
    }
    
    final func findWords(var myletters:String, blocks:Array<Block?>) -> ([String], Array<Block>) {
        var found = [String]()
        var length = count(myletters)
        var myblocks = blocks
        var letters = myletters
        
        while length > shortestWord - 1 {
            for index in shortestWord...length {
                var gotone = checkWord(myletters.substringToIndex(advance(myletters.startIndex, index)))
                if gotone != "" {
                    found.append(gotone)
                }
            }
            myletters = myletters.substringFromIndex(advance(myletters.startIndex, 1))
            length = count(myletters)
        }
        
        if found.count < 1 {
            // println("Found no words in '\(letters)'")
            return([], [])
        }
        // =========DEBUG========= //
        //println("Found \(found.count) words: \(found)")

        var longest = found[0]
        if found.count > 1 {
            for word in found {
                if count(word) > count(longest) {
                    longest = word
                }
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
    
    final func checkWord(word:String) -> String {
        var subjson = json,
        myword = "", letter:String,
        lastword = ""
        
        if ((wordCache[word]) != nil) {
            return ""
        }
        wordCache[word] = -1
        
        var letters = Array(word + "$")
        // println("checkWord: looking for: \(letters)")
        
        for char in letters {
            letter = String(char)
            
            if letter == " " {
                return ""
            }
            
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
        wordCache[word] = 1
        return lastword
    }
    
    func getLetter()->String {
        if letterQueue.count == 0 {
            self.level++
            self.initLetters(Int(ceil(Double(self.level) / 5)))
        }
        /*
        let randomIndex = arc4random_uniform(UInt32(letterQueue.count))
        */
        let letter = letterQueue[0]
        letterQueue.removeAtIndex(0)
        
        return letter
    }
    
    func randomizeLetterQueue(passes:Int) {
        var tmparray:Array<String> = []
        var myletters = self.letterQueue
        var letter:String = ""
        var pick:Int = 0
        
        for pass in 0...passes {
            while (myletters.count > 0) {
                let num = arc4random_uniform(UInt32(myletters.count))
                tmparray.append(myletters[Int(num)])
                myletters.removeAtIndex(Int(num))
            }
        }
        self.letterQueue = tmparray
    }
    
    func initLetters(setCount:Int) {
        let letters = "💣💣AAAAAAAAABBCCDDDDEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ"
        var myletters = letters * setCount
        self.letterQueue.removeAll(keepCapacity: true)
        self.letterQueue = map(letters) { s -> String in String(s) }
        self.randomizeLetterQueue(4)
        
        wordCache.removeAll()
    }
    
    func getPrefs() -> [String:AnyObject] {
        var prefs = NSUserDefaults.standardUserDefaults()
        var myPrefs = [String:AnyObject]()
        var firstRun = !prefs.boolForKey("firstrun")
        
        var bgmusicState : Bool? = prefs.boolForKey("bgmusic")
        if firstRun || bgmusicState == nil {
            bgmusicState = true
            prefs.setBool(true, forKey: "bgmusic")
        }
        myPrefs["bgmusic"] = bgmusicState
        
        var speakState : Bool? = prefs.boolForKey("speak")
        if firstRun || speakState == nil {
            speakState = true
            prefs.setBool(true, forKey: "speak")
        }
        myPrefs["speak"] = speakState
        
        var effectsState : Bool? = prefs.boolForKey("soundeffects")
        if firstRun || effectsState == nil {
            effectsState = true
            prefs.setBool(true, forKey: "soundeffects")
        }
        myPrefs["soundeffects"] = effectsState
        
        var skillState : Int? = prefs.integerForKey("skill")
        if firstRun || skillState == nil {
            skillState = 1
            prefs.setInteger(1, forKey: "skill")
        }
        myPrefs["skill"] = skillState
        prefs.setBool(true, forKey: "firstrun")
        prefs.synchronize()
        
        return myPrefs
    }
    
    init() {
        var path     = NSBundle.mainBundle().pathForResource("all", ofType: "json"),
            url      = NSURL(fileURLWithPath: path!),
            data     = NSData(contentsOfURL: url!),
            content  = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as? [[String: AnyObject]]
        
        self.json = JSON(data: data!)
        self.level = 1
        self.initLetters(1)
        prefs = getPrefs()

    }
    
}

func *(string: String, scalar: Int) -> String {
    let array = Array(count: scalar, repeatedValue: string)
    return "".join(array)
}
