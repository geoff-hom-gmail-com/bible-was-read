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
    
    static let defaultName = "Unnamed Book of the Bible"
    // a book of the bible (don't use "bible book") has to know just how many chapters it has
// oh and its name
    
    var name: String
    // The name usually is not blank, but it can be (e.g., whitespace).
    
    // MARK: Initialization
    
    init(name theName: String = defaultName) {
        
        // Initialize stored properties.
        name = theName
    }
}
