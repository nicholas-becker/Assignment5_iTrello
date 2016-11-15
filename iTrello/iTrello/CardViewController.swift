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
    var store: TrelloStore!
    var list: List!
    
    func removeCard(card: Card) {
        if let index = cardStore.indexOf(card) {
            cardStore.removeAtIndex(index)
        }
    }
    
    func moveCardAtIndex(fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // get reference to card being moved so you can reinsert it
        let movedCard = cardStore[fromIndex]
        // remove card from array
        cardStore.removeAtIndex(fromIndex)
        // insert card in array at new location
        cardStore.insert(movedCard, atIndex: toIndex)
        store.moveCard(movedCard.id, pos: String(toIndex)) {_ in }
    }
    
    @IBAction func addBlankCard(sender: AnyObject) {
        store.createCard() {
            (CardResult) -> Void in switch CardResult {
            case let .Success(card):
                self.addNewCard(self, givenCard: card)
                //print("successfully created a card")
                for each in self.cardStore{
                    //print(each.name)
                    //print(each.id)
                }
                self.tableView.reloadData()
            case let .Failure(error):
                print("Error creating card: \(error)")
            }
        }
        //addNewCard(self, givenCard: Card(name: "New Card", desc: "an empty card", id: "fake id"))

    }
    @IBAction func addNewCard(sender: AnyObject, givenCard: Card?) {
        // create a new card and add it to the store
        if givenCard == nil {
            let newCard = Card(name: "new_Card", desc: "nothing", id: "someNumber123")
            cardStore.append(newCard)
        } else {
            cardStore.append(givenCard!)
        }
        
        // the new card was appended, so it is at the end of the array, but find it cuz the book did so
        if let index = cardStore.indexOf(givenCard!) {
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
        moveCardAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("displaying \(cardStore.count) cells")
        return cardStore.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // if the table view is asking to commit a delete command...
        if editingStyle == .Delete {
            let card = cardStore[indexPath.row]
            
            let title = "Delete \(card.name)?"
            let message = "Are you sure you want to delete this card?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                // remove the card from the store
                self.store.deleteCard(card.id){_ in
                    
                }
                self.removeCard(card)
                
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
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCellCard", forIndexPath: indexPath)
        
        // Set the text on the cell with the name of the card
        // that is at the nth index of cards, where n = row this cell
        // will appear in on the tableview
        let card = cardStore[indexPath.row]
        
        cell.textLabel?.text = card.name
        cell.detailTextLabel?.text = ""     //don't think i need this for cards
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the height of the status bar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        store.getAllCards() {
            (CardsResult) -> Void in switch CardsResult {
            case let .Success(cards):
                for each in cards {
                    self.addNewCard(self, givenCard: each)
                }
                //print("successfully found \(cards.count) cards")
                for each in self.cardStore{
                    //print(each.name)
                    //print(each.id)
                    self.tableView.reloadData()
                }
            case let .Failure(error):
                print("Error fetching cards: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("going from cards to card details")
        print(segue.identifier)
        // if the triggered segue is the "ShowCards" segue
        if segue.identifier == "ShowCardDetails" {
            // figure out which row just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // get the item associated with this row and pass it along
                let card = cardStore[row]
                //print("parent card set to:")
                //print(card.name)
                //print(card.id)
                let cardDetailViewController = segue.destinationViewController as! CardDetailViewController
                cardDetailViewController.card = card
                cardDetailViewController.store = TrelloStore()
                cardDetailViewController.store.parentCard = card
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}