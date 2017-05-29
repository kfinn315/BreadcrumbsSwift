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
    
    internal override init() {
        super.init();
        
        CloudKitManager.sharedInstance.delegate = self;
    }
    
    func addPointToData(point: CLLocation!){
        print("append point");
        
        if #available(iOS 10.0, *) {
            coreData.savePoint(latitude:point.coordinate.latitude, longitude:point.coordinate.longitude, timestamp:point.timestamp)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func SaveCurrentPath(){
        let currentpath = GetCurrentPath();
        SaveCrumb(path: currentpath);
    }
    
    func SaveCrumb(path: Array<CLLocation>){
        print("saveCrumb")
        
        let crumb = Crumb();

        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/YY hh:mm"
        crumb.Title = dateFormatter.string(from: Date())+" "+String(path.count)+" PTS"
        crumb.Path = path;
        
        CloudKitManager.SavePath(crumb);
    }
       func CrumbsReset(){
        CloudKitManager.RemoveAllPaths()
    }
    
    
    func GetCurrentPath() ->Array<CLLocation>{
        var points : [NSManagedObject]?
        
        if #available(iOS 10.0, *) {
            points = coreData.fetchPoints()
        } else {
            // Fallback on earlier versions
        };
        
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
    
    func clearPoints(){
        if #available(iOS 10.0, *) {
            coreData.clearPoints()
        } else {
            // Fallback on earlier versions
        };
    }

    
    //delegate callbacks
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
        
    }
}
