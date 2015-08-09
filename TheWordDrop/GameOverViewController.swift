//
//  GameOverViewController.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 6/24/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    var myView:UIReferenceLibraryViewController?

    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var tilesLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelTitle: UILabel!
    @IBOutlet weak var scoreTitle: UILabel!
    @IBOutlet weak var tilesTitle: UILabel!
    @IBAction func mainmenuAction(sender: UIButton) {
        
    }
    @IBOutlet weak var wordList: UITextView!
    @IBAction func playagainAction(sender: UIButton) {
     }
    override func viewDidAppear(animated: Bool) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = 10
        playButton.layer.borderWidth = 1
        playButton.layer.borderColor = UIColor.clearColor().CGColor

        menuButton.layer.cornerRadius = 10
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = UIColor.clearColor().CGColor

        scoreLabel!.text = String(core.data.score)
        tilesLabel.text = String(core.data.totalTiles)
        levelLabel.text = String(core.data.level)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "textTapped:")
        tapGesture.numberOfTapsRequired = 1
        wordList.addGestureRecognizer(tapGesture)

        var wordlist = NSMutableAttributedString(string: "")
        
        if (core.data.foundWords.count > 0) {
            for w in 0...core.data.foundWords.count - 1 {
                var word = core.data.foundWords[w]
                var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(16.0), "idnum":w, "desc":word, "points":core.data.foundPoints[w], "bonus":core.data.foundBonus[w], NSForegroundColorAttributeName: UIColor.yellowColor() ]
                var bs = "\t"
                if (core.data.foundBonus[w] != "") {
                    attrs["NSBackgroundColorAttributeName"] = UIColor.yellowColor()
                    bs = " [\(core.data.foundBonus[w])] "
                }
                var str = word + "\t\(bs)\t+\(core.data.foundPoints[w])\n"
                var range = NSRange(location: 0, length: count(str))

                var wordText = NSMutableAttributedString(string: str, attributes: attrs)
            
                wordlist.appendAttributedString(wordText)
            }
        }
        wordList.attributedText = wordlist
    }
    
    func adjustFontsForScreenSize() {
        var fontAdjustment = 0
        var screenSize = UIScreen.mainScreen().bounds.size
        
        if screenSize.height == 480 {
            core.data.screenSize = 480
            //println("Detected iPhone 4/4s : screenSize=480")
            // iPhone 4
            fontAdjustment = -2
        } else if screenSize.height == 568 {
            core.data.screenSize = 568
            //println("Detected iPhone 5/5s : screenSize=568")
            // IPhone 5
            fontAdjustment = -1
        } else if screenSize.width == 375 {
            //println("Detected iPhone 6 : screenSize=375")
            core.data.screenSize = 375
            // iPhone 6
            fontAdjustment = 1
        } else if screenSize.width == 414 {
            //println("Detected iPhone 6+ : screenSize=414")
            core.data.screenSize = 414
            // iPhone 6+
            fontAdjustment = 3
        } else if screenSize.width == 768 {
            //println("Detected iPad : screenSize=768")
            core.data.screenSize = 768
            // iPad
            fontAdjustment = 10
            
            NumColumns = 11
            PreviewColumn = 11
            
        }
        
        for lab in [self.menuButton.titleLabel!, self.playButton.titleLabel!, self.levelLabel, self.tilesLabel, self.scoreTitle, self.levelTitle, self.tilesTitle, self.scoreLabel] {
            let f = lab.font
            let s = lab.frame.size
            lab.font = f.fontWithSize(f.pointSize + CGFloat(fontAdjustment))
        }
    }

    func textTapped(recognizer: UITapGestureRecognizer){
        if let textView = recognizer.view as? UITextView {
            let layoutManager = textView.layoutManager
            var location: CGPoint = recognizer.locationInView(textView)
            location.x -= textView.textContainerInset.left
            location.y -= textView.textContainerInset.top
                
            var charIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer,fractionOfDistanceBetweenInsertionPoints: nil)
                
            if charIndex < textView.textStorage.length {
                var range = NSRange(location: 0, length: 0)
                if let idval = textView.attributedText?.attribute("idnum", atIndex: charIndex, effectiveRange: &range) as? NSString {
                    //println("id value: \(idval)")
                    //println("charIndex: \(charIndex)")
                    //println("range.location = \(range.location)")
                    //println("range.length = \(range.length)")
                    let tappedPhrase = (textView.attributedText.string as NSString).substringWithRange(range)
                    //println("tapped phrase: \(tappedPhrase)")
                    var mutableText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
                    mutableText.addAttributes([NSForegroundColorAttributeName: UIColor.yellowColor()], range: range)
                    textView.attributedText = mutableText
                }
                if let desc = textView.attributedText?.attribute("desc", atIndex: charIndex, effectiveRange: &range) as? NSString {
                    self.myView = UIReferenceLibraryViewController(term: desc as String)
                    self.presentViewController(myView!, animated: true, completion: {})

                    // println("desc: \(desc)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}