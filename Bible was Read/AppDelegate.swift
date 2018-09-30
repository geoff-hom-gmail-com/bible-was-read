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
    
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        //TODO: temp; used to get simulator directory for our application (application's sandbox). sqlite is in ../Library/Application Support/
        // Maybe put an ifdef compiler flag if I need to create the default data store
        // can make a Constants struct/file and access global constants there. Like, if (devMakeDefaultDataStore)
        print(NSPersistentContainer.defaultDirectoryURL())
        //TODO: replace with this alt as it's more direct and seems to work
        
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
        
        do {
            let regularSqliteURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Bible-was-Read.sqlite")
            if !(FileManager.default.fileExists(atPath: regularSqliteURL.path)) {
                os_log("regular store was not found. Copy default data store?", log: .default, type: .debug)
                guard let defaultDataSqliteURL = Bundle.main.url(forResource: "DefaultData", withExtension: "sqlite") else {
                    os_log("hmm couldn't find this url", log: .default, type: .debug)
                    fatalError("Unresolved error")
                }
                guard let defaultDataSqliteSHMURL = Bundle.main.url(forResource: "DefaultData", withExtension: "sqlite-shm") else {
                    fatalError("Unresolved error")
                }
                guard let defaultDataSqliteWALURL = Bundle.main.url(forResource: "DefaultData", withExtension: "sqlite-wal") else {
                    fatalError("Unresolved error")
                }
//                let regularSqliteSHMURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Bible-was-Read.sqlite-shm")
                let regularSqliteSHMURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Bible-was-Read.sqlite-shm")
                let regularSqliteWALURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Bible-was-Read.sqlite-wal")


                os_log("ok defaultDataStoreURL was found", log: .default, type: .debug)
                try FileManager.default.copyItem(at: defaultDataSqliteURL, to: regularSqliteURL)
                try FileManager.default.copyItem(at: defaultDataSqliteSHMURL, to: regularSqliteSHMURL)
                try FileManager.default.copyItem(at: defaultDataSqliteWALURL, to: regularSqliteWALURL)

                os_log("wow did it work copying default data store?", log: .default, type: .debug)
                //TODO: this seemed to work but didn't. CD couldn't load the data. Do we need to copy all 3 core data files?
                
            } else {
                os_log("regular store found! Do nothing?", log: .default, type: .debug)
                //temp
                
                

            }
            //TODO: figure out if regular store is there. If not, copy default store to regular store.


        } catch {
            os_log("about to try.", log: .default, type: .debug)
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            // TODO: Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        }
//
//        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let persistentStoreDescription = NSPersistentStoreDescription(url: <#T##URL#>)
//        container.persistentStoreDescriptions = [persistentStoreDescription]
        
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
        //TODO: Load stores. If the normal store doesn't exist, then we want to load the default-data store and use that to create the normal store.
        if wasError {
            // The persistent stores didn't load, so we should alert the user. However, the UI doesn't seem accessible yet (in testing). But because we return nil for biblePersistentContainer, a later alert should appear and give a reasonable alert. (Currently that happens when the user tries to see books of the Bible, triggering MainMenuTableViewController.shouldPerformSegue(withIdentifier:sender:) with showBooksSegueIdentifier.)
            return nil
        }
        return container
    }()
}
