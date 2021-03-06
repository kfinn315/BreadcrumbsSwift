//
//  AppDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import SwiftyBeaver

let log = SwiftyBeaver.self
var cloud : SBPlatformDestination? = nil

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    weak static var managedObjectContext : NSManagedObjectContext? = {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.managedObjectContext
        }
        return nil
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if(UIApplicationLaunchOptionsKey.userActivityType == UIApplicationLaunchOptionsKey.location) {
            let manager = CoreLocationManager()
            manager.startLocationUpdates()
        }
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(rgb: 0xFF9300)
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
        
        setNavColor()
        
        setupSwiftyBeaver()
        
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
        // Called as part of the transition from the background to the inactive state here you can undo many of the changes made on entering the background.
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
    
    @available(iOS 10.0, *)
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
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
        container.loadPersistentStores(completionHandler: { (_, error) in
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
    
    func setNavColor() {
        let primarycolor = UIColor(rgb: 0xFFFC79) //yellow
        let secondarycolor = UIColor(rgb: 0x3854FF) //blue
        
        UINavigationBar.appearance().barTintColor = primarycolor
        UINavigationBar.appearance().tintColor = secondarycolor
        UINavigationBar.appearance().backgroundColor = primarycolor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: secondarycolor]
    }
    
    func setupSwiftyBeaver(){
        //SwiftyBeaver logging setup
        // add log destinations. at least one is needed!
        let console = ConsoleDestination()  // log to Xcode Console
        console.minLevel = SwiftyBeaver.Level.verbose
        
        let file = FileDestination()  // log to default swiftybeaver.log file
        file.minLevel = SwiftyBeaver.Level.debug
        
        cloud = SBPlatformDestination(appID: "g6PqpJ", appSecret: "FXg1ttoIS6a3ifdyu0mpoova3hep0bib", encryptionKey: "gkvvqyHnC4wxrpshsfixinMnbWoqwrXx") // to cloud
        cloud?.minLevel = .verbose
        //
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        // or use this for JSON output: console.format = "$J"
        
        // add the destinations to SwiftyBeaver
        log.addDestination(console)
        log.addDestination(file)
        log.addDestination(cloud!)
    }
}

