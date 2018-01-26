//
//  AppDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        ((window!.rootViewController as! UINavigationController).topViewController as! NavTableViewController).managedObjectContext = self.managedObjectContext
//
        if(UIApplicationLaunchOptionsKey.userActivityType == UIApplicationLaunchOptionsKey.location){
            let manager = CoreLocationManager();
            manager.startLocationUpdates();
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOf: modelURL)!
//    }()
//
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.appendingPathComponent("BreadcrumbsSwift")
//        var failureReason = "There was an error creating or loading the application's saved data."
//
//        do {
//            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
//        } catch {
//            var dict = [String: Any]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//
//            dict[NSUnderlyingErrorKey] = error as NSError
//            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//            abort()
//        }
//
//        return coordinator
//    }()
//
    @available(iOS 10.0, *)
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
//
//        let coordinator = self.persistentContainer.persistentStoreCoordinator
//        //let coordinator = self.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
    }()


    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         applicationd to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Breadcrumbs")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
//    @available(iOS 10.0, *)
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }



}

