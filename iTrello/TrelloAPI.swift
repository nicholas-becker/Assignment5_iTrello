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
    case GET = "1/"
    case POST = "1/cards?"
    case PUT = "1/cards/"
    case DELETE = "1/cards"
    /*
    case DeleteCard
    case RotateOrientation*/
}

enum BoardResult {
    case Success([Board])
    case Failure(ErrorType)
}
enum ListResult {
    case Success([List])
    case Failure(ErrorType)
}
enum CardsResult {
    case Success([Card])
    case Failure(ErrorType)
}
enum CardResult {
    case Success(Card)
    case Failure(ErrorType)
}
enum TrelloError: ErrorType {
    case InvalidJSONData
}

struct TrelloAPI {
    private static let baseURLString = "https://api.trello.com/"
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
    
    static func listsFromJSONData(data: NSData) -> ListResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let lists = jsonObject as? [NSDictionary] else {
                // The JSON structure doesn't match our expectations
                return .Failure(TrelloError.InvalidJSONData)
            }
            var names = [String]()
            var ids = [String]()
            for each in lists {
                guard let theName = each["name"] as? String, theId = each["id"] as? String else {
                    // I don't understand this
                    return .Failure(TrelloError.InvalidJSONData)
                }
                names.append(theName)
                ids.append(theId)
            }
            
            var finalLists = [List]()
            for each in names {
                finalLists.append( List(name: each, id: ids[names.indexOf(each)!]) )
            }
            
            if finalLists.count == 0 && lists.count > 0 {
                // we couldn't parse the lists and one existed
                return .Failure(TrelloError.InvalidJSONData)
            }
            return .Success(finalLists)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    static func cardsFromJSONData(data: NSData) -> CardsResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let cards = jsonObject as? [NSDictionary] else {
                // The JSON structure doesn't match our expectations
                return .Failure(TrelloError.InvalidJSONData)
            }
            var names = [String]()
            var ids = [String]()
            var descs = [String]()
            for each in cards {
                guard let theName = each["name"] as? String, theId = each["id"] as? String , theDesc = each["desc"] as? String else {
                    // I don't understand this
                    return .Failure(TrelloError.InvalidJSONData)
                }
                names.append(theName)
                ids.append(theId)
                descs.append(theDesc)
            }
            
            var finalCards = [Card]()
            for each in names {
                finalCards.append( Card(name: each, desc: descs[names.indexOf(each)!], id: ids[names.indexOf(each)!]) )
            }
            
            if finalCards.count == 0 && cards.count > 0 {
                // we couldn't parse the cards and one existed
                return .Failure(TrelloError.InvalidJSONData)
            }
            return .Success(finalCards)
        }
        catch let error {
            return .Failure(error)
        }
    }
    static func cardFromJSONData(data: NSData) -> CardResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            print(jsonObject)
            guard let card = jsonObject as? [NSObject:AnyObject], name = card["name"] as? String, id = card["id"] as? String, desc = card["desc"] as? String else {
                // The JSON structure doesn't match our expectations
                return .Failure(TrelloError.InvalidJSONData)
            }

            let finalCard = Card(name: name, desc: desc, id: id)

            return .Success(finalCard)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    private static func trelloURL(method method: Method, urlString: String, parameters: [String:String]?) -> NSURL {
        let startString = baseURLString + method.rawValue + urlString
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
    
    static func GetBoardsURL() -> NSURL {
        return trelloURL(method: .GET, urlString: "members/me/boards?", parameters: [:])
    }
    static func GetListsURL(boardId: String) -> NSURL {
        return trelloURL(method: .GET, urlString: "boards/\(boardId)/lists?", parameters: [:])
    }
    static func GetCardsURL(listId: String) -> NSURL {
        return trelloURL(method: .GET, urlString: "lists/\(listId)/cards?", parameters: [:])
    }
    static func EditCard(cardId: String, name: String, desc: String) ->NSURL {
        return trelloURL(method: .PUT, urlString: "cards/\(cardId)?", parameters: ["name":name, "desc":desc])
    }
    
    static func CreateCardURL(name: String, desc: String, listId: String) -> NSURL {
        return trelloURL(method: .POST, urlString: "", parameters: ["name": name, "desc": desc, "due": "null", "idList":listId])
    }
    static func EditCardURL(name: String, desc: String, cardId: String) -> NSURL {
        return trelloURL(method: .PUT, urlString: "\(cardId)?", parameters: ["name": name, "desc": desc, "due": "null"])
    }
    static func DeleteCardURL(cardId: String) -> NSURL {
        return trelloURL(method: .DELETE, urlString: "/\(cardId)?", parameters: [:])
    }
    static func MoveCardURL(cardId: String, pos: String) -> NSURL {
        return trelloURL(method: .PUT, urlString: "\(cardId)/pos?", parameters: ["pos": pos])
    }
}