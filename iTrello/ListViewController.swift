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
    var store: TrelloStore!
    var board: Board!
    
    func removeList(list: List) {
        if let index = listStore.indexOf(list) {
            listStore.removeAtIndex(index)
        }
    }
    
    func moveListAtIndex(fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // get reference to list being moved so you can reinsert it
        let movedList = listStore[fromIndex]
        // remove list from array
        listStore.removeAtIndex(fromIndex)
        // insert list in array at new location
        listStore.insert(movedList, atIndex: toIndex)
    }
    
    @IBAction func addBlankList(sender: AnyObject) {
        addNewList(self, givenList: List(name: "New List", id: "fake id"))
    }
    @IBAction func addNewList(sender: AnyObject, givenList: List?) {
        // create a new list and add it to the store
        if givenList == nil {
            let newList = List(name: "new_List", id: "someNumber123")
            listStore.append(newList)
        } else {
            listStore.append(givenList!)
        }
        
        // the new list was appended, so it is at the end of the array, but find it cuz the book did so
        if let index = listStore.indexOf(givenList!) {
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
        moveListAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("displaying \(listStore.count) cells")
        return listStore.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // if the table view is asking to commit a delete command...
        if editingStyle == .Delete {
            let list = listStore[indexPath.row]
            
            let title = "Delete \(list.name)?"
            let message = "Are you sure you want to delete this list?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                // remove the list from the store
                self.removeList(list)
                
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
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCellList", forIndexPath: indexPath)
        
        // Set the text on the cell with the name of the list
        // that is at the nth index of lists, where n = row this cell
        // will appear in on the tableview
        let list = listStore[indexPath.row]
        
        cell.textLabel?.text = list.name
        cell.detailTextLabel?.text = ""     //don't think i need this for lists
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("loading lists from board:")
        //print(board.name)
        //print(board.id)
        // get the height of the status bar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        store.getAllLists() {
            (ListResult) -> Void in switch ListResult {
            case let .Success(lists):
                for each in lists {
                    self.addNewList(self, givenList: each)
                }
                //print("successfully found \(lists.count) lists")
                for each in self.listStore{
                    //print(each.name)
                    //print(each.id)
                    self.tableView.reloadData()
                }
            case let .Failure(error):
                print("Error fetching lists: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("going from list to cards")
        //print(segue.identifier)
        // if the triggered segue is the "ShowCards" segue
        if segue.identifier == "ShowCards" {
            // figure out which row just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // get the item associated with this row and pass it along
                let list = listStore[row]
                //print("parent list of cards set to:")
                //print(list.name)
                print(list.id)
                let cardViewController = segue.destinationViewController as! CardViewController
                cardViewController.list = list
                cardViewController.store = TrelloStore()
                cardViewController.store.parentList = list
                cardViewController.store.parentBoard = board
                cardViewController.cardStore = [Card]()
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}