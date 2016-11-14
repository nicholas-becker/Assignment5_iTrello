//
//  TrelloAPI.swift
//  iTrello
//
//  Created by Nicholas Becker on 10/31/16.
//  Copyright © 2016 ismoresimpler. All rights reserved.
//

import Foundation

let myToken = "6c20888c363e034d6f59a9f1b2451260e0688c113b0ca9df59a3e2f3e31cbca6"
let mySecret = "12c3d8a686977ac9e7fdcdb40d42a3779738c0264454a3209bca2a7139873462"

enum Method: String {
    // each case is a requirement, may be able to remove some of them
    case GETBoards = "members/me/boards?"
    case POST
    case PUT
    case DELETE
    /*
    case ViewBoards
    case ViewList
    case ViewCard
    case CreateCard
    case UpdateNameAndDescription
    case DeleteCard
    case RotateOrientation*/
}

enum BoardResult {
    case Success([Board])
    case Failure(ErrorType)
}

enum TrelloError: ErrorType {
    case InvalidJSONData
}

struct TrelloAPI {
    private static let baseURLString = "https://api.trello.com/1/"
    private static let APIKey = "12a09d6cbbe7ceed3adf4effdd6c87d0"
    
    static func boardsFromJSONData(data: NSData) -> BoardResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let boards = jsonObject as? [NSDictionary] else {
                // The JSON structure doesn't match our expectations
                return .Failure(TrelloError.InvalidJSONData)
            }
            var names = [String]()
            var ids = [String]()
            for each in boards {
                guard let theName = each["name"] as? String, theId = each["id"] as? String else {
                    // I don't understand this
                    return .Failure(TrelloError.InvalidJSONData)
                }
                names.append(theName)
                ids.append(theId)
            }
            
            var finalBoards = [Board]()
            for each in names {
                finalBoards.append( Board(name: each, id: ids[names.indexOf(each)!]) )
            }
            
            if finalBoards.count == 0 && boards.count > 0 {
                // we couldn't parse the boards and one existed
                return .Failure(TrelloError.InvalidJSONData)
            }
            return .Success(finalBoards)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    private static func trelloURL(method method: String, parameters: [String:String]?) -> NSURL {
        let startString = baseURLString + method
        let components = NSURLComponents(string: startString)!
        
        var queryItems = [NSURLQueryItem]()
        let baseParams = ["key": APIKey, "token": myToken]
        
        for (key, value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.URL!
    }
    
    static func ViewBoardsURL() -> NSURL {
        return trelloURL(method: "members/me/boards?", parameters: [:])
    }
    static func GetListsURL(boardId: String) -> NSURL {
        return trelloURL(method: "boards/\(boardId)/lists?", parameters: [:])
    }
    static func GetCardsURL(listId: String) -> NSURL {
        return trelloURL(method: "lists/\(listId)/cards?", parameters: [:])
    }
    
    static func CreateCardURL() -> NSURL {
        return trelloURL(method: "FIXTHIS!!!", parameters: ["name": "name_val", "desc": "desc_val", "pos": "pos_val", "due": "due_val", "idList": "idList_val"])
    }
}