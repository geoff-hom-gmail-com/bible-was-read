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
    
    /// Returns a Bible with nothing read; if error, the "Bible" has only a dummy book.
    static func blankBooks() -> [BookOfTheBible] {
        
//        let blankBookOfTheBible = BookOfTheBible(context: persistentContainer.viewContext)
//        blankBookOfTheBible.name = "Can't Find Blank Books"
//        return [blankBookOfTheBible]
        
        // Blank Bible data is in a text file. Read it and parse.
        guard let blankBooksURL = Bundle.main.url(forResource: BlankBooksFilename, withExtension: BlankBooksSuffix) else {

            os_log("Can't find file with blank books: %@.", log: OSLog.default, type: .debug, BlankBooksFilename + BlankBooksSuffix)
            return [BookOfTheBible(name: "Can't Find Blank Books")]
        }
        do {
            let csvText = try String(contentsOf: blankBooksURL, encoding: .utf8)
//            os_log("Blank books: %@.", log: OSLog.default, type: .debug, csvText)

            // Clean up newlines.
            let cleanedCSVText = csvText.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")

            var lines = cleanedCSVText.components(separatedBy: CharacterSet.newlines)

            // Assume a header of Book, Chapter, Verse. Remove it.
            let header = lines.removeFirst()
            os_log("Header: %@.", log: OSLog.default, type: .debug, header)

            // Initialize first book.
            guard let firstLine = lines.first else {
                os_log("File has only one line, which should be the header.", log: OSLog.default, type: .debug)
                return [BookOfTheBible(name: "File has only header")]
            }
            let firstBookFirstChapterInfo = firstLine.components(separatedBy: ",")

            var currentBookName = firstBookFirstChapterInfo[0]
            var currentBook = BookOfTheBible(name: currentBookName)
            var books = [BookOfTheBible]()
            for line in lines {
                let chapterInfo = line.components(separatedBy: ",")

                // If new book name, add old book and make new book.
                let bookName = chapterInfo[0]
                if bookName != currentBookName {
                    books.append(currentBook)

                    currentBookName = bookName
                    currentBook = BookOfTheBible(name: currentBookName)
                }

                // Add chapter to book.
                let chapterName = chapterInfo[1]
                var chapter = Chapter(name: chapterName)
                if let numVerses = Int(chapterInfo[2]) {
                    for _ in 1...numVerses {
                        chapter.verses.append(Verse())
                    }
                }
                currentBook.chapters.append(chapter)
            }

            // Add last book.
            books.append(currentBook)

            return books
        }
        catch {
            os_log("Blank-books file exists, but can't read it: %@.", log: OSLog.default, type: .debug, String(describing: error))
            return [BookOfTheBible(name: "Can't Read Blank Books")]
        }
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
    
    // Return saved books of the Bible. If none, return default (blank) data.
    static func savedBooks() -> [BookOfTheBible]? {
//        return BookOfTheBibleManager.blankBooks(persistentContainer: persistentContainer)

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
