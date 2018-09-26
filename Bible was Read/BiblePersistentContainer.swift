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
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                os_log("Saved!", log: .default, type: .debug)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Loading data
    
//     (a Bible with nothing read; i.e., "blank").
    //TODO: Go thru this function and clean it up manually.
    func defaultBooks() -> [BookOfTheBible]? {
        /// Returns a Bible with nothing read; if error, the "Bible" has only a dummy book.
        
        let defaultDataFilename = "ChapterAndVerseList"
        let defaultDataSuffix = "csv"
        // The default data is in a human-readable .csv file. The .csv was exported from a Google spreadsheet.
        
        guard let defaultDataURL = Bundle.main.url(forResource: defaultDataFilename, withExtension: defaultDataSuffix) else {
            os_log("Can't find default data: %@ not found.", log: .default, type: .error, defaultDataFilename + defaultDataSuffix)
//            let genericBook = BookOfTheBible(context: viewContext)
//            genericBook.name = "Can't find default data"
            return nil
        }
        // If the default data isn't found, then return

        // Blank Bible data is in a text file. Read it and parse.

        do {
            let csvText = try String(contentsOf: defaultDataURL, encoding: .utf8)
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
            
            var importOrder = 1
            // To assign book ID, to preserve order.
            var currentBook = BookOfTheBible(context: viewContext)
            currentBook.id = Int16(importOrder)
            var currentBookName = firstBookFirstChapterInfo[0]
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
                    importOrder += 1
                    currentBook.id = Int16(importOrder)
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
            saveContext()
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
    
    func savedBooks() -> [BookOfTheBible]? {
        /// Return saved books of the Bible. Else, return default data.
        let request: NSFetchRequest<BookOfTheBible> = BookOfTheBible.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            let books = try viewContext.fetch(request)
            if books.isEmpty {
                os_log("No saved books were found. Loading default data.", log: .default, type: .default)
                return defaultBooks()
            } else {
                os_log("Books of the Bible were found! Loading.", log: .default, type: .default)
                return books
            }
        } catch {
            os_log("Unable to load saved books: %@. Loading default data.", log: .default, type: .default, String(describing: error))
            return defaultBooks()
        }
        // When fetching the data, it can fail two ways: Fetch throws an error, or fetch returns an empty array. In both cases, we want to return default data.
    }
}
