//
//  BookOfTheBibleTableViewController.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/22/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit
import CoreData
import os.log

class BookOfTheBibleTableViewController: UITableViewController {
    // MARK: Properties
    
    var booksOfTheBibleOld: [BookOfTheBibleOld]!
    var booksOfTheBible: [BookOfTheBible]!
    // Initialized in viewDidLoad().
    
    var biblePersistentContainer: BiblePersistentContainer!
    // Conceptually a constant, as the value is set by the parent and never changed.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Get table data.
        os_log("Pre savedBooks call.", log: .default, type: .debug)
        booksOfTheBible = biblePersistentContainer.savedBooks()
        os_log("Post savedBooks call.", log: .default, type: .debug)
        // testing timing/performance
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
//        return booksOfTheBibleOld.count
        return booksOfTheBible.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table-view cells are reused and should be dequeued.
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath)
        
        // Populate the cell.
//        let book = booksOfTheBibleOld[indexPath.row]
        let book = booksOfTheBible[indexPath.row]
        cell.textLabel?.text = book.name
        
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
        case "ShowChapters":
            guard let chapterTableViewController = segue.destination as? ChapterTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedBookOfTheBible = booksOfTheBible[indexPath.row]
            chapterTableViewController.bookOfTheBible = selectedBookOfTheBible
            // Set selected book.
        default:
            ()
        }
    }

}
