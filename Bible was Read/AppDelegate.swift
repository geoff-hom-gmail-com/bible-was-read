//
//  AppDelegate.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/19/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit
import CoreData
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// Override point for customization after application launch.
        
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return true
        }
        guard let mainMenuTableViewController = navigationController.viewControllers.first as? MainMenuTableViewController else {
            return true
        }
        mainMenuTableViewController.biblePersistentContainer = biblePersistentContainer
        // Apple recommends, "… pass a reference to the (persistent) container to your user interface." (https://developer.apple.com/documentation/coredata/making_core_data_your_model_layer)
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //TODO: figure out if best practice to save MOC here.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        biblePersistentContainer?.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var biblePersistentContainer: BiblePersistentContainer? = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it.
         
         This is an optional so, even without a store, the user can access other app
         we can preserve other app functions, especially feedback/help.
         */
        let container = BiblePersistentContainer(name: "Bible-was-Read")
        var wasError = false
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                os_log("Error: Can't load persistent store: %@.", log: .default, type: .error, error.localizedDescription)
                wasError = true
            }
        })
        if wasError {
            // The persistent stores didn't load, so we should alert the user. However, the UI doesn't seem accessible yet (in testing). But because we return nil for biblePersistentContainer, a later alert should appear and give a reasonable alert. (Currently that happens when the user tries to see books of the Bible, triggering MainMenuTableViewController.shouldPerformSegue(withIdentifier:sender:) with showBooksSegueIdentifier.)
            return nil
        }
        return container
    }()
}
