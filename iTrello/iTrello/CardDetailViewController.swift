//
//  CardDetailViewController.swift
//  iTrello
//
//  Created by Nicholas Becker on 11/14/16.
//  Copyright © 2016 ismoresimpler. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var descriptionField: UITextField!
       
    var card: Card!
    var store: TrelloStore!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = card.name
        descriptionField.text = card.desc
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
               
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Clear first responder
        view.endEditing(true)
        
        // "save" changes to card
        card.name = nameField.text ?? ""
        card.desc = descriptionField.text ?? ""
        store.parentCard = card
        store.editCard() {
            (CardResult) -> Void in switch CardResult {
            case let .Success(card):
                print("successfully edited a card")
                //print(card.name)
                //print(card.id)
            case let .Failure(error):
                print("Error editing card: \(error)")
            }
        }
    }
}