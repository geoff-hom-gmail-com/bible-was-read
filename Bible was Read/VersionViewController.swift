//
//  ViewController.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/19/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit

class VersionViewController: UIViewController {

    // MARK: Properties

    @IBOutlet weak var versionLabel: UILabel!
    // Shows the current version (and build).

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let mainBundle = Bundle.main
        let version = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "Not found"
//        let build = mainBundle.object(forInfoDictionaryKey: "CFBundleVersion") ?? "Not found"
        let build = mainBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "Not found"
        // kCFBundleVersionKey is the constant for "CFBundleVersion," but there's no equivalent for "CFBundleShortVersionString."
        
        versionLabel.text = "Bible was Read, version \(version) (build \(build))."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

