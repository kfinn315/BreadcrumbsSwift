//
//  CrumbsManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/9/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import CoreData
import UIKit

class CrumbsManager: NSObject, CloudKitDelegate {
    var coreData = CoreDataManager();
    var delegate : CrumbsDelegate?;
    static var CurrentCrumb : PathsType?;
    
    internal override init() {
        super.init();
        
        CloudKitManager.sharedInstance.delegate = self;
    }
    
    func addPointToData(point: CLLocation!) throws {
        print("append point");
        
            try coreData.savePoint(latitude:point.coordinate.latitude, longitude:point.coordinate.longitude, timestamp:point.timestamp)
    }
    
    func SaveCurrentPath() throws {
        CloudKitManager.sharedInstance.delegate = self;
        let currentpath = try GetCurrentPath();
        try SaveCrumb(path: currentpath);
    }
    
    private func SaveCrumb(path: Array<CLLocation>) throws {
        print("saveCrumb")
        
        let crumb = Crumb();

        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/YY hh:mm"
        crumb.Title = dateFormatter.string(from: Date())+" "+String(path.count)+" PTS"
        crumb.Path = path;
        
         try CloudKitManager.SavePath(crumb);
    }
    
    func GetCurrentPath() throws ->Array<CLLocation>{
        var points : [NSManagedObject]?
        
        points = try coreData.fetchPoints()
        
        var currentPath = Array<CLLocation>();
        // currentPath.removeAll()
        for point in points! {
            let lat = point.value(forKey: "latitude") as! Double
            let long = point.value(forKey: "longitude") as! Double
            let clLat = CLLocationDegrees(lat)
            let clLong = CLLocationDegrees(long)
            
            currentPath.append(CLLocation(latitude: clLat, longitude: clLong))
        }
        
        return currentPath;
    }
    
    func clearPoints() throws{
            try coreData.clearPoints()
    }

    
    //delegate callbacks
    func CrumbsReset() throws {
        try CloudKitManager.RemoveAllPaths()
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        print("crumb saved");
        //  currentPath.removeAll();
        self.delegate?.CrumbSaved(Id);
    }
    
    func errorUpdatingCrumbs(_ Error: Error) {
        delegate?.errorUpdatingCrumbs(Error)
    }
    
    func errorSavingData(_ Error: Error) {
        delegate?.errorSavingData(Error)
    }
    
    func CrumbDeleted(_ RecordID: CKRecordID) {
    }
    
    func CrumbsUpdated(_ Crumbs: Array<PathsType>) {
        self.delegate?.CrumbsUpdated(Crumbs);
    }
}
