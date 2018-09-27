//
//  VerseCollectionViewController.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/25/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit
import os.log

private let reuseIdentifier = "VerseCollectionViewCell"

class VerseCollectionViewController: UICollectionViewController {

    // MARK: Properties
    
    var biblePersistentContainer: BiblePersistentContainer?
    // Basically a constant, as the value is set by the parent and never changed.
    // Tried this as an IUO, but really didn't like it. (Type-checking was confusing.)

    var bookName: String?
    // Basically a constant, as the value is set by the parent and never changed.
    // Tried this as an IUO, but really didn't like it. (Type-checking was confusing.)

    var chapter: Chapter?
    // Basically a constant, as the value is set by the parent and never changed.
    // Tried this as an IUO, but really didn't like it. (Type-checking was confusing.)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Register cell classes (or storyboard can register a nib file)
        
        navigationItem.title = "\(bookName ?? "") \(chapter?.name ?? "")"
        self.collectionView?.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapter?.verses?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let verseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VerseCollectionViewCell
        verseCollectionViewCell.layer.borderWidth = 1
        verseCollectionViewCell.layer.cornerRadius = 4
        let index = indexPath.row
        if let verse = chapter?.verses?[index] as? Verse {
            verseCollectionViewCell.label.text = String(index + 1)
            if verse.wasRead {
                verseCollectionViewCell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                // selectItem(at:animated:scrollPosition:) is needed to fix a bug (upon load, previously selected cells can't be tapped) (https://stackoverflow.com/questions/15330844/uicollectionview-select-and-deselect-issue). And if isSelected is removed, then selected cells don't look selected (i.e. background color not changed) until user taps a cell.
            }
            // If verse was read, show that.
        }
        //TODO: use guard instead of nested if?
        return verseCollectionViewCell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        os_log("Cell shouldSelectItemAt?", log: .default, type: .debug)
//        return true
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        os_log("Cell shouldDeselectItemAt?", log: .default, type: .debug)
//        return true
//    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (chapter?.verses?[indexPath.row] as? Verse)?.wasRead = true
        // Mark verse as read.
        //TODO: clean up; try let verse = ...
        biblePersistentContainer?.saveContext()
//        os_log("Cell selected: %i.", log: .default, type: .debug, indexPath.row + 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (chapter?.verses?[indexPath.row] as? Verse)?.wasRead = false
        // Mark verse as unread.
        //TODO: clean up; try let verse = ... Also we're duping didSelectItemAt...
        biblePersistentContainer?.saveContext()
//        os_log("Cell deselected: %i.", log: .default, type: .debug, indexPath.row + 1)
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
