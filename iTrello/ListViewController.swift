//
//  ListViewController.swift
//  iTrello
//
//  Created by Nicholas Becker on 11/13/16.
//  Copyright © 2016 ismoresimpler. All rights reserved.
//

import UIKit

class List: NSObject {
    var name: String
    var id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        
        super.init()
    }
}

class ListViewController: UITableViewController {
    var listStore: [List]!
    
    
}