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

    var observations = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Register cell classes (or storyboard can register a nib file)
        
        navigationItem.title = "\(bookName ?? "") \(chapter?.name ?? "")"
        collectionView?.allowsMultipleSelection = true
        observeVerses()
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
        guard let verse = chapter?.verses?[indexPath.row] as? Verse else {
            return
        }
        verse.wasRead = true
        biblePersistentContainer?.saveContext()
        // Mark verse as read.
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let verse = chapter?.verses?[indexPath.row] as? Verse else {
            return
        }
        verse.wasRead = false
        biblePersistentContainer?.saveContext()
        // Mark verse as unread.
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
    
    // MARK: KVO

    func observeVerses() {
        // Observe each verse's wasRead, to update numVersesRead.
        guard let verses = chapter?.verses?.array as? [Verse] else {
            return
        }
        for verse in verses {
            observations.append(verse.observe(\.wasRead, options: [.new]) {
                verse, change in
                os_log("wasRead changed.", log: .default, type: .debug)
                guard let wasRead = change.newValue else {
                    return
                }
                if wasRead {
                    verse.chapter?.numVersesRead += 1
                    verse.chapter?.book?.numVersesRead += 1
                } else {
                    verse.chapter?.numVersesRead -= 1
                    verse.chapter?.book?.numVersesRead -= 1
                }
                // KVO is synchronous. We assume changes will be saved because wasRead changed, so we won't save here.

                guard let numVersesRead = verse.chapter?.numVersesRead,
                    let bookNumVersesRead = verse.chapter?.book?.numVersesRead else {
                    return
                }
                os_log("numVersesRead: %d", log: .default, type: .debug, Int(numVersesRead))
                os_log("bookNumVersesRead: %d", log: .default, type: .debug, Int(bookNumVersesRead))
                // testing: make sure these start at 0 and both go up and down correctly
            })
            // todo: if/when we allow "mark all" for a given book (not chapter), we may have to revisit this.
        }
    }
}
