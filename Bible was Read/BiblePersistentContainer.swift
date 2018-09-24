//
//  BiblePersistentContainer.swift
//  Bible was Read
//
//  Created by Geoff Hom on 9/21/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit
import CoreData
import os.log

class BiblePersistentContainer: NSPersistentContainer {
    // MARK: File Paths
    
    //these don't need to be static, or at least we'd call them only from here; figure this out
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let SavedBooksURL = DocumentsDirectory.appendingPathComponent("books")
    static let BlankBooksFilename = "ChapterAndVerseList"
    static let BlankBooksSuffix = "csv"
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - ??
    
    //TODO: Once we're reading from a proper JSON file, go thru this function and lint it manually.
    func blankBooks() -> [BookOfTheBible] {
        /// Returns a Bible with nothing read; if error, the "Bible" has only a dummy book.
        // Blank Bible data is in a text file. Read it and parse.
        guard let blankBooksURL = Bundle.main.url(forResource: BiblePersistentContainer.BlankBooksFilename, withExtension: BiblePersistentContainer.BlankBooksSuffix) else {
            
            os_log("Can't find file with blank books: %@.", log: .default, type: .error, BiblePersistentContainer.BlankBooksFilename + BiblePersistentContainer.BlankBooksSuffix)
            
            let genericBook = BookOfTheBible(context: viewContext)
            genericBook.name = "Can't Find Blank Books"

            return [genericBook]
        }
        do {
            let csvText = try String(contentsOf: blankBooksURL, encoding: .utf8)
            //            os_log("Blank books: %@.", log: OSLog.default, type: .debug, csvText)
            
            // Clean up newlines.
            let cleanedCSVText = csvText.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
            
            var lines = cleanedCSVText.components(separatedBy: CharacterSet.newlines)
            
            // Assume a header of Book, Chapter, Verse. Remove it.
            let header = lines.removeFirst()
            os_log("Header: %@.", log: .default, type: .debug, header)
            
            // Initialize first book.
            guard let firstLine = lines.first else {
                os_log("File has only one line, which should be the header.", log: .default, type: .debug)
                let genericBook = BookOfTheBible(context: viewContext)
                genericBook.name = "File has only header"
                return [genericBook]
            }
            let firstBookFirstChapterInfo = firstLine.components(separatedBy: ",")
            
            var currentBookName = firstBookFirstChapterInfo[0]
            var currentBook = BookOfTheBible(context: viewContext)
            currentBook.name = currentBookName
    
            var books = [BookOfTheBible]()
            for line in lines {
                let chapterInfo = line.components(separatedBy: ",")
                
                // If new book name, add old book and make new book.
                let bookName = chapterInfo[0]
                if bookName != currentBookName {
                    books.append(currentBook)
                    
                    currentBookName = bookName
                    currentBook = BookOfTheBible(context: viewContext)
                    currentBook.name = currentBookName
                }
                
                // Add chapter to book.
                let chapterName = chapterInfo[1]
                let chapter = Chapter(context: viewContext)
                chapter.name = chapterName
                if let numVerses = Int(chapterInfo[2]) {
                    for _ in 1...numVerses {
                        chapter.addToVerses(Verse(context: viewContext))
                    }
                }
                currentBook.addToChapters(chapter)
            }
            
            // Add last book.
            books.append(currentBook)
            
            return books
        }
        catch {
            os_log("Blank-books file exists, but can't read it: %@.", log: .default, type: .debug, String(describing: error))
            
            let genericBook = BookOfTheBible(context: viewContext)
            genericBook.name = "Can't Read Blank Books"
            
            return [genericBook]
        }

    }
    
    /// Returns a Bible with nothing read; if error, the "Bible" has only a dummy book.
//    static func blankBooks() -> [BookOfTheBible] {
//
//
//        // Blank Bible data is in a text file. Read it and parse.
//        guard let blankBooksURL = Bundle.main.url(forResource: BlankBooksFilename, withExtension: BlankBooksSuffix) else {
//
//            os_log("Can't find file with blank books: %@.", log: OSLog.default, type: .debug, BlankBooksFilename + BlankBooksSuffix)
//            return [BookOfTheBible(name: "Can't Find Blank Books")]
//        }
//        do {
//            let csvText = try String(contentsOf: blankBooksURL, encoding: .utf8)
//            //            os_log("Blank books: %@.", log: OSLog.default, type: .debug, csvText)
//
//            // Clean up newlines.
//            let cleanedCSVText = csvText.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
//
//            var lines = cleanedCSVText.components(separatedBy: CharacterSet.newlines)
//
//            // Assume a header of Book, Chapter, Verse. Remove it.
//            let header = lines.removeFirst()
//            os_log("Header: %@.", log: OSLog.default, type: .debug, header)
//
//            // Initialize first book.
//            guard let firstLine = lines.first else {
//                os_log("File has only one line, which should be the header.", log: OSLog.default, type: .debug)
//                return [BookOfTheBible(name: "File has only header")]
//            }
//            let firstBookFirstChapterInfo = firstLine.components(separatedBy: ",")
//
//            var currentBookName = firstBookFirstChapterInfo[0]
//            var currentBook = BookOfTheBible(name: currentBookName)
//            var books = [BookOfTheBible]()
//            for line in lines {
//                let chapterInfo = line.components(separatedBy: ",")
//
//                // If new book name, add old book and make new book.
//                let bookName = chapterInfo[0]
//                if bookName != currentBookName {
//                    books.append(currentBook)
//
//                    currentBookName = bookName
//                    currentBook = BookOfTheBible(name: currentBookName)
//                }
//
//                // Add chapter to book.
//                let chapterName = chapterInfo[1]
//                var chapter = Chapter(name: chapterName)
//                if let numVerses = Int(chapterInfo[2]) {
//                    for _ in 1...numVerses {
//                        chapter.verses.append(Verse())
//                    }
//                }
//                currentBook.chapters.append(chapter)
//            }
//
//            // Add last book.
//            books.append(currentBook)
//
//            return books
//        }
//        catch {
//            os_log("Blank-books file exists, but can't read it: %@.", log: OSLog.default, type: .debug, String(describing: error))
//            return [BookOfTheBible(name: "Can't Read Blank Books")]
//        }
//    }
    
    func savedBooks() -> [BookOfTheBible] {
        /// Return saved books of the Bible. Else, return default data (a Bible with nothing read; i.e., "blank").
        let request: NSFetchRequest<BookOfTheBible> = BookOfTheBible.fetchRequest()
        do {
            let books = try viewContext.fetch(request)
            if books.isEmpty {
                os_log("No books of the Bible were found. Loading default data.", log: .default, type: .default)
                return blankBooks()
            } else {
                return books
            }
        } catch {
            os_log("Unable to load saved books of the Bible: %@. Loading default data.", log: .default, type: .default, String(describing: error))
            return blankBooks()
        }
        // When fetching the data, it can fail two ways: Fetch throws an error, or fetch returns an empty array. In both cases, we want to return default data.
    }

    // Return saved books of the Bible. If none, return default (blank) data.
//    static func savedBooks() -> [BookOfTheBible]? {
//        //        return BookOfTheBibleManager.blankBooks(persistentContainer: persistentContainer)
//
//        // Swift 4 Codable.
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
//    }
}
