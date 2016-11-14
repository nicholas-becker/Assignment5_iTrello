//
//  BoardViewController.swift
//  iTrello
//
//  Created by Nicholas Becker on 10/31/16.
//  Copyright © 2016 ismoresimpler. All rights reserved.
//

import UIKit

class TrelloStore {
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    func getAllBoards(completion completion: (BoardResult) -> Void) {
        let url = TrelloAPI.ViewBoardsURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processGetAllBoardsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    func processGetAllBoardsRequest(data data: NSData?, error: NSError?) ->  BoardResult{
        guard let jsonData = data else {
            return .Failure(error!)
        }
        return TrelloAPI.boardsFromJSONData(jsonData)
    }
}

class Board {
    let name: String
    let id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
}

class BoardViewController: UITableViewController {
    var store: TrelloStore!
    var boardStore: [Board]!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("displaying \(boardStore.count) cells")
        return boardStore.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("creating cell")
        //get a new or recycled cell
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCellBoard", forIndexPath: indexPath)
        
        // Set the text on the cell with the name of the board
        // that is at the nth index of boards, where n = row this cell
        // will appear in on the tableview
        let board = boardStore[indexPath.row]
        
        cell.textLabel?.text = board.name
        cell.detailTextLabel?.text = ""     //don't think i need this for boards
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the height of the status bar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        store.getAllBoards() {
            (BoardResult) -> Void in switch BoardResult {
            case let .Success(boards):
                for each in boards {
                    self.boardStore.append(each)
                }
                print("successfully found \(boards.count) boards")
                for each in self.boardStore{
                    print(each.name)
                    print(each.id)
                }
            case let .Failure(error):
                print("Error fetching boards: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

