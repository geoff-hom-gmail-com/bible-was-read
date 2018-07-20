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
    static let BlankBooksFilename = "ChapterAndVerseList"
    static let BlankBooksSuffix = "csv"
    
    // MARK: Default Data
    
    static func blankBooks() -> [BookOfTheBible] {
        // TODO: add descriptive comment here.
        
        // TODO: Let's read from the file and print out what it says.
        guard let blankBooksURL = Bundle.main.url(forResource: BlankBooksFilename, withExtension: BlankBooksSuffix) else {
            
            os_log("Can't find file with blank books: %@.", log: OSLog.default, type: .debug, BlankBooksFilename + BlankBooksSuffix)
            return [BookOfTheBible(name: "Can't Find Blank Books")]
        }
        do {
            let csvText = try String(contentsOf: blankBooksURL, encoding: .utf8)
            //keep going
            os_log("Blank books: %@.", log: OSLog.default, type: .debug, csvText)
            // clean csv text?
            let cleanedCSV = csvText.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
            // get each line
            let rows = cleanedCSV.components(separatedBy: CharacterSet.newlines)
            //TODO: This prints the book, chapter, verse. Want to build that into BookOfTheBible object.
            for row in rows {
                let columns = row.components(separatedBy: ",")
                for column in columns {
                    os_log("column entry: %@.", log: OSLog.default, type: .debug, column)
                }
            }
        }
        catch {
            os_log("Blank-books file exists, but can't read it: %@.", log: OSLog.default, type: .debug, String(describing: error))
            //TODO: this is dup code; refactor
            return [BookOfTheBible(name: "Can't Find Blank Books")]
        }

//        let url = BookOfTheBibleManager.SavedBooksURL
//        let decoder = JSONDecoder()
//        do {
//            let data = try Data(contentsOf: url)
//            let books = try decoder.decode([BookOfTheBible].self, from: data)
//            return books
//        } catch {
//            os_log("Unable to load symptoms: %@. Loading blank data.", log: OSLog.default, type: .debug, String(describing: error))
//            return BookOfTheBibleManager.blankBooks()
//        }
        
//        let url = Bundle.main.url(forResource: "BooksOfTheBible", withExtension: "txt")
//
//        
//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            
//            let fileURL = dir.appendingPathComponent(file)
//            
//           
//            //reading
//            do {
//                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
//            }
//            catch {/* error handling here */}
//        }
//        
//        
//        let dir = try? FileManager.default.url(for: .documentDirectory,
//                                               in: .userDomainMask, appropriateFor: nil, create: true)
//        
//        // If the directory was found, we write a file to it and read it back
//        
//        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
//            
// 
//            // Then reading it back from the file
//            var inString = ""
//            do {
//                inString = try String(contentsOf: fileURL)
//            } catch {
//                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
//            }
//            print("Read from the file: \(inString)")
//        }
        
        // this is temp. really want to read from a text file
        var book1 = BookOfTheBible(name: "Matthew")
        var tempChapter = Chapter(name: "1")
        tempChapter.verses.append(Verse())
        book1.chapters.append(tempChapter)
        var book2 = BookOfTheBible(name: "Mark")
        tempChapter = Chapter(name: "1")
        for _ in 1...5 {
            tempChapter.verses.append(Verse())
        }
        book2.chapters.append(contentsOf: [tempChapter, Chapter(name: "2")])
        var book3 = BookOfTheBible(name: "Luke")
        for index in 1...5 {
            book3.chapters.append(Chapter(name: String(index)))
        }
//        book3.chapters.append(contentsOf: chapters)

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
