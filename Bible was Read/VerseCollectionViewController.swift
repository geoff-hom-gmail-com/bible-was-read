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
    
    var bookName: String!
    // Conceptually a constant, as the value is set by the parent and never changed.

    var chapter: Chapter!
    // Conceptually a constant, as the value is set by the parent and never changed.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes (or storyboard can register a nib file)
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        navigationItem.title = "\(bookName ?? "") \(chapter.name)"
        // 6.27.18: IUO isn't implicitly unwrapped, so using ??.
        
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
        
        // temp check
        os_log("verses: %i.", log: OSLog.default, type: .info, chapter.verses.count)
        return chapter.verses.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let verseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VerseCollectionViewCell
        
        verseCollectionViewCell.layer.borderWidth = 1
        verseCollectionViewCell.layer.cornerRadius = 4
        
        // Populate the cell.
        verseCollectionViewCell.label.text = String(indexPath.row + 1)

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
//        return true
//    }

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
