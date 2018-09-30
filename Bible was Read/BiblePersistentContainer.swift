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

protocol BiblePersistentContainerDelegate: AnyObject {
    func biblePersistentContainer(_ container: BiblePersistentContainer, didMakeAlert alert: UIAlertController)
    // The container made an alert, as it knows what happened and why. The container isn't part of the UI, so showing the alert is up to the delegate.
    // An alert is made if the default data file isn't found, can't be read, or has only a header (i.e., is only one line).
}

class BiblePersistentContainer: NSPersistentContainer {
    // MARK: - Properties
    
    weak var delegate: BiblePersistentContainerDelegate?
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                os_log("Context saved.", log: .default, type: .debug)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Loading data
    
    func defaultBooks() -> [BookOfTheBible]? {
        /// Returns a Bible with nothing read.
        
        let defaultDataFilename = "ChapterAndVerseList"
        let defaultDataSuffix = "csv"
        // The default data is in a human-readable .csv file. The file has a header. Then, each line describes one chapter: book name, chapter, and number of verses. (The .csv was exported from a Google spreadsheet.)
        
        guard let defaultDataURL = Bundle.main.url(forResource: defaultDataFilename, withExtension: defaultDataSuffix) else {
            os_log("Default-data file not found (%@).", log: .default, type: .error, "\(defaultDataFilename).\(defaultDataSuffix)")
            let alert = UIAlertController(title: "Can't Find Default Data",
                                          // "Can't Find X" seems good diction, as the user knows the app needs something.
                                          message: "Not found: \(defaultDataFilename).\(defaultDataSuffix).",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            delegate?.biblePersistentContainer(self, didMakeAlert: alert)
            return nil
        }
        // If the default-data file wasn't found, then alert the user.

        do {
            let csvText = try String(contentsOf: defaultDataURL, encoding: .utf8)
            
            let cleanedCSVText = csvText.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
            // Clean up newlines.

            let lines = cleanedCSVText.components(separatedBy: CharacterSet.newlines)
            let chapterLines = lines.dropFirst()
            // Remove header.

            guard !chapterLines.isEmpty else {
                os_log("Default data had only one line (presumably the header).", log: .default, type: .error)
                let alert = UIAlertController(title: "Can't Find Default Data",
                                              // "Can't Find X" seems good diction, as the user knows the app needs something.
                    message: "\(defaultDataFilename).\(defaultDataSuffix) has only one line (presumably the header).",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                delegate?.biblePersistentContainer(self, didMakeAlert: alert)
                return nil
            }
            // If the default-data file had only one line (a removed "header"), then alert the user.
        
            var books = [BookOfTheBible]()
            // For storing the default data.
            
            for chapterLine in chapterLines {
                let chapterInfo = chapterLine.components(separatedBy: ",")
                
                let previousBookName = books.last?.name
                let bookName = chapterInfo[0]
                if bookName != previousBookName {
                    let book = BookOfTheBible(context: viewContext)
                    let previousID = books.last?.id
                    book.id = Int16((previousID ?? 0) + 1)
                    // Increment ID to preserve the order of the books.
                    book.name = bookName
                    books.append(book)
                }
                // If the book name is new, then make that book.
                
                let chapter = Chapter(context: viewContext)
                chapter.name = chapterInfo[1]
                if let numVerses = Int(chapterInfo[2]) {
                    for _ in 1...numVerses {
                        chapter.addToVerses(Verse(context: viewContext))
                    }
                }
                books.last?.addToChapters(chapter)
                // Make the chapter. Add it to the most recent book.
            }
            // Read default data and parse.
            
            saveContext()
            // Save default data to disk.
            
            return books
        }
        catch {
            os_log("Default-data file exists, but can't read it: %@.", log: .default, type: .error, String(describing: error))
            let alert = UIAlertController(title: "Can't Read Default Data",
                                          // "Can't X" seems good diction, as the user knows the app needs something.
                message: "Found default data but can't read it: \(String(describing: error)).",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            delegate?.biblePersistentContainer(self, didMakeAlert: alert)
            return nil
        }
        // If the default-data file couldn't be read, then alert the user.
    }

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
