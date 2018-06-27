//
//  BookOfTheBibleTableViewController.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/22/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit

class BookOfTheBibleTableViewController: UITableViewController {

    // MARK: Properties
    
    var booksOfTheBible: [BookOfTheBible]!
    // Initialized in viewDidLoad().

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Get table data.
        booksOfTheBible = BookOfTheBibleManager.savedBooks()
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
        return booksOfTheBible.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table-view cells are reused and should be dequeued.
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath)
        
        // Populate the cell.
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
        // Prepare before navigation segue.

        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ShowChapters":
            guard let chapterTableViewController = segue.destination as? ChapterTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Set selected book.
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
//            symptomDetailViewController.delegate = self
            let selectedBookOfTheBible = booksOfTheBible[indexPath.row]
            chapterTableViewController.bookOfTheBible = selectedBookOfTheBible
//            symptomDetailViewController.symptomIndex = indexPath.row
        default:
            ()
        }
    }

}
