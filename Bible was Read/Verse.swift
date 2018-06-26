//
//  Verse.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/25/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import Foundation

struct Verse: Codable {
    
    // MARK: Properties
    
    var wasRead: Bool
    
    // MARK: Initialization

    // call: Verse(wasRead: true)
    
    init(wasRead: Bool = false) {
        
        // Initialize stored properties.
        self.wasRead = wasRead
    }
}
