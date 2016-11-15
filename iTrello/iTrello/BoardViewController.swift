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
    var parentBoard: Board!
    var parentList: List!
    var parentCard: Card!
    
    func getAllBoards(completion completion: (BoardResult) -> Void) {
        let url = TrelloAPI.GetBoardsURL()
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
    
    func getAllLists(completion: (ListResult) -> Void) {
        //print("getting lists for board")
        //print(parentBoard.name)
        //print(parentBoard.id)
        let url = TrelloAPI.GetListsURL(parentBoard.id)
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processGetAllListsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    func processGetAllListsRequest(data data: NSData?, error: NSError?) ->  ListResult{
        guard let jsonData = data else {
            return .Failure(error!)
        }
        return TrelloAPI.listsFromJSONData(jsonData)
    }
    
    func getAllCards(completion: (CardsResult) -> Void) {
        let url = TrelloAPI.GetCardsURL(parentList.id)
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processGetAllCardsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    func processGetAllCardsRequest(data data: NSData?, error: NSError?) ->  CardsResult{
        guard let jsonData = data else {
            return .Failure(error!)
        }
        return TrelloAPI.cardsFromJSONData(jsonData)
    }
    func createCard(completion: (CardResult) -> Void) {
        let url = TrelloAPI.CreateCardURL("New Card", desc: "describe the card here", listId: parentList.id)
        //print(url)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        //print(request)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processCreateCardRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    func processCreateCardRequest(data data: NSData?, error: NSError?) ->  CardResult{
        guard let jsonData = data else {
            //print(data)
            return .Failure(error!)
        }
        return TrelloAPI.cardFromJSONData(jsonData)
    }
    func editCard(completion: (CardResult) -> Void) {
        let url = TrelloAPI.EditCardURL(parentCard.name, desc: parentCard.desc, cardId: parentCard.id)
        //print(url)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        //print(request)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processEditCardRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    func processEditCardRequest(data data: NSData?, error: NSError?) ->  CardResult{
        guard let jsonData = data else {
            //print(data)
            return .Failure(error!)
        }
        return TrelloAPI.cardFromJSONData(jsonData)
    }
    func deleteCard(cardId: String, completion: (CardResult) -> Void) {
        let url = TrelloAPI.DeleteCardURL(cardId)
        //print(url)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        //print(request)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processDeleteCardRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    func processDeleteCardRequest(data data: NSData?, error: NSError?) ->  CardResult{
        guard let jsonData = data else {
            //print(data)
            return .Failure(error!)
        }
        return TrelloAPI.cardFromJSONData(jsonData)
    }
    func moveCard(cardId: String, pos: String, completion: (CardResult) -> Void) {
        let url = TrelloAPI.MoveCardURL(cardId, pos: pos)
        //print(url)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        //print(request)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processEditCardRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    func processMoveCardRequest(data data: NSData?, error: NSError?) ->  CardResult{
        guard let jsonData = data else {
            //print(data)
            return .Failure(error!)
        }
        return TrelloAPI.cardFromJSONData(jsonData)
    }
}

class Board: NSObject {
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
    
    func removeBoard(board: Board) {
        if let index = boardStore.indexOf(board) {
            boardStore.removeAtIndex(index)
        }
    }
    
    func moveBoardAtIndex(fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // get reference to board being moved so you can reinsert it
        let movedBoard = boardStore[fromIndex]
        // remove board from array
        boardStore.removeAtIndex(fromIndex)
        // insert board in array at new location
        boardStore.insert(movedBoard, atIndex: toIndex)
    }
    
    @IBAction func addBlankBoard(sender: AnyObject) {
        addNewBoard(self, givenBoard: Board(name: "New Board", id: "fake id"))
    }
    @IBAction func addNewBoard(sender: AnyObject, givenBoard: Board?) {
        // create a new board and add it to the store
        if givenBoard == nil {
            let newBoard = Board(name: "new_Board", id: "someNumber123")
            boardStore.append(newBoard)
        } else {
            boardStore.append(givenBoard!)
        }
        
        // the new board was appended, so it is at the end of the array, but find it cuz the book did so
        if let index = boardStore.indexOf(givenBoard!) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            // Insert this new row into the table
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    @IBAction func toggleEditingMode(sender: AnyObject) {
        // If you are currently in editing mode...
        if editing {
            // change text of button to inform user of state
            sender.setTitle("Edit", forState: .Normal)
            
            // turn off editing mode
            setEditing(false, animated: true)
        }
        else {
            // change text of button to inform user of state
            sender.setTitle("Done", forState: .Normal)
            
            // Enter editing mode
            setEditing(true, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // update the model
        moveBoardAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("displaying \(boardStore.count) cells")
        return boardStore.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // if the table view is asking to commit a delete command...
        if editingStyle == .Delete {
            let board = boardStore[indexPath.row]
            
            let title = "Delete \(board.name)?"
            let message = "Are you sure you want to delete this board?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                // remove the board from the store
                self.removeBoard(board)
                
                // also remove that row from the table view with an animation
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
            ac.addAction(deleteAction)
            
            // present the alert controller
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
                    self.addNewBoard(self, givenBoard: each)
                }
                //print("successfully found \(boards.count) boards")
                for each in self.boardStore{
                    //print(each.name)
                    //print(each.id)
                    self.tableView.reloadData()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("going from board to list")
        // if the triggered segue is the "ShowLists" segue
        if segue.identifier == "ShowLists" {
            // figure out which row just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // get the item associated with this row and pass it along
                let board = boardStore[row]
                //print("parent board of list set to:")
                //print(board.name)
                //print(board.id)
                let listViewController = segue.destinationViewController as! ListViewController
                listViewController.board = board
                listViewController.store = TrelloStore()
                listViewController.store.parentBoard = board
                listViewController.listStore = [List]()
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}

