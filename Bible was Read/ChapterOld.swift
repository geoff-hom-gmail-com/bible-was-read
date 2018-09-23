//
//  Chapter.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/25/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import Foundation

struct ChapterOld: Codable {

    // MARK: Properties

    var name: String

    var wasRead: Bool

    var verses = [VerseOld]()
    // A chapter is created, then verses are added.

    // MARK: Initialization

    // (temp) call: Chapter(name: "1", wasRead: true)
    init(name: String, wasRead: Bool = false) {

        // Initialize stored properties.
        self.name = name
        self.wasRead = wasRead
    }
}
