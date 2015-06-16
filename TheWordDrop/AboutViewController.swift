//
//  AboutViewController.swift
//  TheWordDrop
//
//  Created by Christopher Robison on 6/15/15.
//  Copyright (c) 2015 Christopher Robison. All rights reserved.
//
import UIKit

class AboutViewController: UITableViewController {
    
    @IBAction func emailAction(sender: UIButton) {
        let email = "cdr@cdr2.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}