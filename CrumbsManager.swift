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
    import CoreMotion
    
    class CrumbsManager: NSObject, CloudKitDelegate {
        var coreData = CoreDataManager();
        var delegate : CrumbsDelegate?;
        static var CurrentCrumb : PathsType?;
        var pedometer = CMPedometer()
        
        internal override init() {
            super.init();
            
            CloudKitManager.sharedInstance.delegate = self;
        }
        
        func addPointToData(_ point: Point) throws {
            print("append point");
            
            try coreData.savePoint(point)
        }
        
        func SaveCurrentPath(start: Date?, end: Date?, title: String, description: String?) throws {
            //CloudKitManager.sharedInstance.delegate = self;
            let points = try coreData.fetchPoints();
            let path = Path()
            
            do{
                path.pointsJSON = String(data: try JSONEncoder().encode(points), encoding: .utf8)
            }
            catch{
                print("error "+error.localizedDescription)
            }
            path.title = title
            path.notes = description ?? ""
            
            if start != nil, end != nil {
                path.startdate = start! as NSDate
                path.enddate = end! as NSDate

                getSteps(start!, end!, callback: { (data, error) -> (Void) in
                    if error == nil {
                        if data != nil {
                            print("steps: \(data!.numberOfSteps)")
                            print("est distance: \(data!.distance ?? 0)")
                            path.stepcount = data!.numberOfSteps
                            path.distance = data!.distance?.doubleValue ?? 0
                        } else {
                            print("step data is nil")
                        }
                    }
                    else {
                        print("error "+error!.localizedDescription)
                    }
                    
                    self.coreData.savePath(path)
                })
            } else{
                coreData.savePath(path)
            }
        }
        func getSteps(_ start: Date, _ end: Date, callback: @escaping CMPedometerHandler) {
//            guard  CMPedometer.authorizationStatus() == CMAuthorizationStatus.authorized else{
//                callback(nil, LocalError.failed(message: "pedometer use is not authorized"))
//                return
//            }
            
            guard CMPedometer.isStepCountingAvailable() else{
                callback(nil, LocalError.failed(message: "step counting is not available"))
                return
            }
            
            pedometer.queryPedometerData(from: start, to: end, withHandler: callback)
            
            return
        }
        
        private func SavePathToCloud(_ path: Path) throws {
            print("saveCrumb")
            
            //  let crumb = Path();
            
            //        let dateFormatter = DateFormatter();
            //        dateFormatter.dateFormat = "MM/dd/YY hh:mm"
            //path.Date = Date()// dateFormatter.string(from: Date())
            //        crumb.Title = dateFormatter.string(from: Date())+" "+String(path.count)+" PTS"
            //        crumb.Points = path;
            
            try CloudKitManager.SavePath(path);
        }
        
        //    func GetCurrentPoints() throws ->Array<Point>{
        //        var points = try coreData.fetchPoints()
        //
        //        var currentPath = Array<CLLocation>();
        //        // currentPath.removeAll()
        //        for point in points! {
        //            let lat = point.value(forKey: "latitude") as! Double
        //            let long = point.value(forKey: "longitude") as! Double
        //            let clLat = CLLocationDegrees(lat)
        //            let clLong = CLLocationDegrees(long)
        //
        //            currentPath.append(CLLocation(latitude: clLat, longitude: clLong))
        //        }
        //
        //        return currentPath;
        //    }
        
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
    
