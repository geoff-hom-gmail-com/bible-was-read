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
}
