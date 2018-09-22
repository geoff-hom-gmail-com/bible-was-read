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
    
    func blankBooks() -> [BookOfTheBible2] {
        /// Returns a Bible with nothing read; if error, the "Bible" has only a dummy book.
        // for now, let's just load this from the JSON file

        // Blank Bible data is in a text file. Read it and parse.
        guard let blankBooksURL = Bundle.main.url(forResource: BiblePersistentContainer.BlankBooksFilename, withExtension: BiblePersistentContainer.BlankBooksSuffix) else {
            
            os_log("Can't find file with blank books: %@.", log: .default, type: .error, BiblePersistentContainer.BlankBooksFilename + BiblePersistentContainer.BlankBooksSuffix)
            
            // what context does it use here? it could use a default, but how does it know where that is?
            let genericBook = BookOfTheBible2()
            genericBook.name = "Can't Find Blank Books"
//            let genericBook2 = BookOfTheBible2(context: viewContext)

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
            os_log("Header: %@.", log: OSLog.default, type: .debug, header)
            
            // Initialize first book.
            guard let firstLine = lines.first else {
                os_log("File has only one line, which should be the header.", log: .default, type: .debug)
                
                let genericBook = BookOfTheBible2()
                genericBook.name = "File has only header"
                
                return [genericBook]
            }
            let firstBookFirstChapterInfo = firstLine.components(separatedBy: ",")
            
            var currentBookName = firstBookFirstChapterInfo[0]
            
            
            var currentBook = BookOfTheBible2()
            currentBook.name = currentBookName
            
            
            var books = [BookOfTheBible2]()
            for line in lines {
                let chapterInfo = line.components(separatedBy: ",")
                
                // If new book name, add old book and make new book.
                let bookName = chapterInfo[0]
                if bookName != currentBookName {
                    books.append(currentBook)
                    
                    currentBookName = bookName
                    currentBook = BookOfTheBible2()
                    currentBook.name = currentBookName

                }
                
                // Add chapter to book.
                let chapterName = chapterInfo[1]
                var chapter = Chapter(name: chapterName)
                if let numVerses = Int(chapterInfo[2]) {
                    for _ in 1...numVerses {
                        chapter.verses.append(Verse())
                    }
                }
//                currentBook.chapters.append(chapter)
                // hmm this is an nsset?, not a swift Set, etc. Do I want to convert it to a swift type, or just use nsset stuff?
                // keeping this as an nsorderedset for now; may change to an array if a pain?
//                let chaptersMutableSet = currentBook.chapters
//                mutableSet.add(chapter)
                // ah, this would have to be Chapter2; for now blank it
//                currentBook.addToChapters(<#T##value: Chapter2##Chapter2#>)
//                currentBook.addToChapters(chapter)
            }
            
            // Add last book.
            books.append(currentBook)
            
            return books
        }
        catch {
            os_log("Blank-books file exists, but can't read it: %@.", log: .default, type: .debug, String(describing: error))
            
            let genericBook = BookOfTheBible2()
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
    
    // Return saved books of the Bible. If none, return default data.
    // Default should be a Bible with nothing read(blank Bible).
    func savedBooks() -> [BookOfTheBible2] {
        os_log("BPC savedBooks called", log: .default, type: .debug)
        let request: NSFetchRequest<BookOfTheBible2> = BookOfTheBible2.fetchRequest()
        
        do {
            let books = try viewContext.fetch(request)
            // I think this worked even though it was empty/nil, because we haven't saved anything yet and the line below still came up.
            os_log("Fetch worked!", log: .default, type: .debug)
            return books
        } catch {
            os_log("Unable to load saved books: %@. Loading blank data.", log: .default, type: .error, String(describing: error))
            return blankBooks()
        }
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
