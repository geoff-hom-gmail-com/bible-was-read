//
//  BooksOfTheBibleManager.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/25/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import Foundation
import os.log

class BookOfTheBibleManager: NSObject {

    // MARK: File Paths
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let SavedBooksURL = DocumentsDirectory.appendingPathComponent("books")
    
    // MARK: Default Data
    
    static func blankBooks() -> [BookOfTheBible] {
        // this is temp. really want to read from a text file
        var book1 = BookOfTheBible(name: "Matthew")
        var book2 = BookOfTheBible(name: "Mark")
        var book3 = BookOfTheBible(name: "Luke")
        
        return [book1, book2, book3]
    }
    
    // MARK: Save/Load
    
//    static func deleteSavedSymptoms() {
//        // Delete saved symptoms.
//
//        let url = SymptomManager.SavedSymptomsURL
//        do {
//            try FileManager.default.removeItem(at: url)
//            os_log("Symptoms deleted.", log: OSLog.default, type: .debug)
//        } catch {
//            os_log("Unable to delete symptoms: %@", log: OSLog.default, type: .debug, String(describing: error))
//        }
//    }
//
//    static func saveSymptom(_ symptom: Symptom, at index: Int) {
//        // Replace saved symptom at index.
//
//        guard var savedSymptoms = SymptomManager.savedSymptoms() else {
//            os_log("Can't save; no previously saved symptoms.", log: OSLog.default, type: .error)
//            return
//        }
//        savedSymptoms[index] = symptom
//        SymptomManager.saveSymptoms(savedSymptoms)
//    }
//
//    static func saveSymptoms(_ symptoms: [Symptom]) {
//
//        // Swift 4 Codable.
//        let encoder = JSONEncoder()
//        let fileManager = FileManager.default
//        let url = SymptomManager.SavedSymptomsURL
//        do {
//            let data = try encoder.encode(symptoms)
//            if fileManager.fileExists(atPath: url.path) {
//                try fileManager.removeItem(at: url)
//            }
//            let wasSuccess = fileManager.createFile(atPath: url.path, contents: data)
//            if wasSuccess {
//                os_log("Symptoms saved.", log: OSLog.default, type: .debug)
//            } else {
//                os_log("Failed to save symptoms.", log: OSLog.default, type: .error)
//            }
//        } catch {
//            os_log("Failed to save symptoms: %@", log: OSLog.default, type: .error, String(describing: error))
//        }
//    }
    
    static func savedBooks() -> [BookOfTheBible]? {
        // Return saved books of the Bible. If none, return default (blank) data.
        
        // Swift 4 Codable.
        let url = BookOfTheBibleManager.SavedBooksURL
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url)
            let books = try decoder.decode([BookOfTheBible].self, from: data)
            return books
        } catch {
            os_log("Unable to load symptoms: %@. Loading blank data.", log: OSLog.default, type: .debug, String(describing: error))
            return BookOfTheBibleManager.blankBooks()
        }
    }
}
