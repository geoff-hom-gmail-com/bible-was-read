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
    
    static func copyDefaultData(appName: String) {
        /// The first time this app is used: instead of creating a blank data store, copy the default data.
        let defaultDataName = "DefaultData"
        let sqliteExtension = "sqlite"
        let shmExtension = "\(sqliteExtension)-shm"
        let walExtension = "\(sqliteExtension)-wal"
        let coreDataDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        do {
            let regularSqliteURL = coreDataDirectoryURL.appendingPathComponent("\(appName).\(sqliteExtension)")
            guard !FileManager.default.fileExists(atPath: regularSqliteURL.path) else {
                return
            }
            // The regular .sqlite isn't there, so we'll copy the default data.
            os_log("First time running app? Loading default data.", log: .default, type: .default)
            guard let defaultDataSqliteURL = Bundle.main.url(forResource: defaultDataName, withExtension: sqliteExtension) else {
                os_log("Error: Can't find file: %@.", log: .default, type: .error, "\(defaultDataName).\(sqliteExtension)")
                return
            }
            guard let defaultDataSqliteSHMURL = Bundle.main.url(forResource: defaultDataName, withExtension: shmExtension) else {
                os_log("Error: Can't find file: %@.", log: .default, type: .error, "\(defaultDataName).\(shmExtension)")
                return
            }
            guard let defaultDataSqliteWALURL = Bundle.main.url(forResource: defaultDataName, withExtension: walExtension) else {
                os_log("Error: Can't find file: %@.", log: .default, type: .error, "\(defaultDataName).\(walExtension)")
                return
            }
            let regularSqliteSHMURL = coreDataDirectoryURL.appendingPathComponent("\(appName).\(shmExtension)")
            let regularSqliteWALURL = coreDataDirectoryURL.appendingPathComponent("\(appName).\(walExtension)")
            
            let preDate = Date()
            try FileManager.default.copyItem(at: defaultDataSqliteURL, to: regularSqliteURL)
            try FileManager.default.copyItem(at: defaultDataSqliteSHMURL, to: regularSqliteSHMURL)
            try FileManager.default.copyItem(at: defaultDataSqliteWALURL, to: regularSqliteWALURL)
            os_log("Time to copy default data: %.3f.", log: .default, type: .default, preDate.timeIntervalSinceNow)
        } catch {
            os_log("Can't copy default data: %@.", log: .default, type: .error, String(describing: error))
        }
    }
    
    func makeDefaultData() {
        /*
         Loads the default data from a text file and saves it to Core Data. This is an expensive task, so the developer should do this ahead of time, then use that as a default-data store.
         
         General workflow:
         • Delete the app in the simulator, so there's no Core Data store.
         • Call this function, like in application(_:didFinishLaunchingWithOptions:).
         • Check the console to find the directory with the Core Data files.
         • Rename the 3 .sqlite files to the prefix "DefaultData". Put those files in the Xcode project, under the group "DefaultData".
         • Comment out the function call.
         • Delete app in simulator again, to test reading from the default-data store.
         
         When the user first runs the app, another function should take the default-data store and copy it to the Core Data directory.
         */
        let preDate = Date()
        let defaultDataFilename = "ChapterAndVerseList"
        let defaultDataSuffix = "csv"
        // The default data is in a human-readable .csv file. The file has a header. Then, each line describes one chapter: book name, chapter, and number of verses. (The .csv was exported from a Google spreadsheet.)
        
        guard let defaultDataURL = Bundle.main.url(forResource: defaultDataFilename, withExtension: defaultDataSuffix) else {
            os_log("Default-data file not found (%@).", log: .default, type: .error, "\(defaultDataFilename).\(defaultDataSuffix)")
            return
        }
        
        do {
            let csvText = try String(contentsOf: defaultDataURL, encoding: .utf8)
            
            let cleanedCSVText = csvText.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
            // Clean up newlines.
            
            let lines = cleanedCSVText.components(separatedBy: CharacterSet.newlines)
            let chapterLines = lines.dropFirst()
            // Remove header.
            
            guard !chapterLines.isEmpty else {
                os_log("Default data had only one line (presumably the header).", log: .default, type: .error)
                return
            }
            
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
            
            os_log("Time for defaultBooks(): %.3f.", log: .default, type: .default, preDate.timeIntervalSinceNow)
        }
        catch {
            os_log("Default-data file exists, but can't read it: %@.", log: .default, type: .error, String(describing: error))
        }
        os_log("Default data made. Location: %@.", log: .default, type: .default, NSPersistentContainer.defaultDirectoryURL().absoluteString)
    }

    func savedBooks() -> [BookOfTheBible]? {
        /// Return saved books of the Bible. Else, nil.
        let request: NSFetchRequest<BookOfTheBible> = BookOfTheBible.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            let books = try viewContext.fetch(request)
            os_log("Found the Books of the Bible.", log: .default, type: .default)
            return books
        } catch {
            os_log("Can't load saved books: %@.", log: .default, type: .error, String(describing: error))
            return nil
        }
    }    
}
