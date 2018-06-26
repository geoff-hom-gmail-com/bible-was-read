//
//  BookOfTheBible.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/22/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import Foundation

struct BookOfTheBible: Codable {
    
    // MARK: Properties
    
//    static let defaultName = "Unnamed"
    
    var wasRead: Bool

    var name: String
    
    var chapters = [Chapter]()
    // A book of the Bible is created, then chapters are added.

    // MARK: Initialization
    
    // call: BookOfTheBible(name: "John", wasRead: true)
    init(name: String, wasRead: Bool = false) {
        
        // Initialize stored properties.
        self.name = name
        self.wasRead = wasRead
    }
}
