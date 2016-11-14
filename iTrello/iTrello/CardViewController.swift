//
//  CardViewController.swift
//  iTrello
//
//  Created by Nicholas Becker on 11/13/16.
//  Copyright © 2016 ismoresimpler. All rights reserved.
//

import UIKit

class Card: NSObject {
    var name: String
    var desc: String
    var id: String
    
    init(name: String, desc: String, id: String) {
        self.name = name
        self.desc = desc
        self.id = id
        
        super.init()
    }
}

class CardViewController: UITableViewController {
    var cardStore: [Card]!
    

}