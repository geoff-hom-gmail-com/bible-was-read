//
//  VerseCollectionViewCell.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/28/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit

class VerseCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties

    @IBOutlet weak var label: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.backgroundColor = UIColor.green
            }
            else {
                self.backgroundColor = nil
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
//            A highlight toggle doesn't guarantee a selection toggle: User can drag finger away. didSets are:
//            1) Became selected: green,
//            2) Became unselected: nil,
//            3) Became highlighted, was not selected: green,
//            4) Became unhighlighted, was not selected: nil,
//            5) Became highlighted, was selected: nil,
//            6) Became unhighlighted, was selected: green.
            if (self.isHighlighted && !self.isSelected) ||
                (!self.isHighlighted && self.isSelected) {
                self.backgroundColor = UIColor.green
            }
            else {
                self.backgroundColor = nil
            }
        }
    }
}
