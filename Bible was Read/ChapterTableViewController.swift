//
//  ChapterTableViewController.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/26/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit
import os.log

class ChapterTableViewController: UITableViewController {
    // MARK: Properties
    
    var biblePersistentContainer: BiblePersistentContainer?
    // Basically a constant, as the value is set by the parent and never changed.
    // Tried this as an IUO, but really didn't like it. (Type-checking was confusing.)

    var bookOfTheBible: BookOfTheBible?
    // Basically a constant, as the value is set by the parent and never changed.
    // Tried this as an IUO, but really didn't like it. (Type-checking was confusing.)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = bookOfTheBible?.name

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookOfTheBible?.chapters?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterTableViewCell", for: indexPath)
        // Table-view cells are reused and should be dequeued.
        
        guard let chapter = bookOfTheBible?.chapters?[indexPath.row] as? Chapter else {
            os_log("Could not get chapter for row.", log: .default, type: .debug)
            cell.textLabel?.text = String(indexPath.row + 1)
            return cell
        }
        guard let verses = chapter.verses?.array as? [Verse] else {
            os_log("Could not get verses for chapter.", log: .default, type: .debug)
            cell.textLabel?.text = chapter.name
            return cell
        }
        let totalVerses = verses.count
        var numVersesRead = 0
        for verse in verses {
            if verse.wasRead {
                numVersesRead += 1
            }
        }
        let percentVersesRead = Double(numVersesRead) * 100.0 / Double(totalVerses)
        let percentVersesReadRounded = String(format: "%.0f", percentVersesRead)
        // Percent rounded to nearest integer. E.g., Genesis 1 with 3/31 should be 10% (9.7%).
        cell.textLabel?.text = "\(chapter.name ?? "") (\(percentVersesReadRounded)%)"
        // Text should be like "1 (0%)", "1 (100%)", "1 (4%)".

        // TODO: does cell update when coming back from VerseCVC? It should. Nope, no update when coming back. Only forward. Fix.
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ShowVerses":
            guard let verseCollectionViewController = segue.destination as? VerseCollectionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            verseCollectionViewController.biblePersistentContainer = biblePersistentContainer
            verseCollectionViewController.bookName = bookOfTheBible?.name
            // Set selected book's name.
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            guard let selectedChapter = bookOfTheBible?.chapters?[indexPath.row] as? Chapter else {
                fatalError("Could not get selected chapter.")
            }
            verseCollectionViewController.chapter = selectedChapter
            // Set selected chapter.
        default:
            ()
        }
    }
}
