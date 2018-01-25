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
    
    class CrumbsManager: NSObject {//}, CloudKitDelegate {
        var pathsManager = PathsManager();
        var pointsManager = PointsManager();
        var delegate : CrumbsDelegate?;
        var pedometer = CMPedometer()
        
        var currentPath : Path?
        
        private static var _shared : CrumbsManager?
        class var shared : CrumbsManager {
            if _shared == nil {
                _shared = CrumbsManager()
            }
            
            return _shared!
        }
        
        private override init() {
            super.init();
        }
        
        func UpdateCurrentAlbum(collection: PhotoCollection) -> Int{
            guard currentPath != nil, currentPath!.id != nil else{ return -1 }
            
            currentPath?.albumData = collection
            return UpdateCurrentPath(albumid: collection.id)
        }
        
        //returns number of paths updated
        private func UpdateCurrentPath(albumid: String) -> Int{
            guard currentPath != nil, currentPath!.id != nil else{ return -1 }

            let propUpdates : [AnyHashable:Any] = ["albumId": albumid]
                
                let count = pathsManager.updatePath(id: currentPath!.id!, properties: propUpdates)
                if let id = currentPath?.id {
                    currentPath = pathsManager.getPath(id)
                }
                return count
        }
        
        //returns number of paths updated
        func UpdateCurrentPath() -> Int{
            guard currentPath != nil, currentPath!.id != nil else{ return -1 }
            
                let count = pathsManager.updatePath(currentPath!)
                if let id = currentPath?.id {
                    currentPath = pathsManager.getPath(id)
                }
                return count
        }
        
        func SaveNewPath(start: Date?, end: Date?, title: String, description: String?) {
            let points = pointsManager.fetchPoints();
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
                    
                    self.pathsManager.savePath(path)
                })
            } else{
                pathsManager.savePath(path)
            }
        }
        private func getSteps(_ start: Date, _ end: Date, callback: @escaping CMPedometerHandler) {
            guard CMPedometer.isStepCountingAvailable() else{
                callback(nil, LocalError.failed(message: "step counting is not available"))
                return
            }
            
            pedometer.queryPedometerData(from: start, to: end, withHandler: callback)
            
            return
        }
        
        func addPointToData(_ point: Point) {
            print("append point");
            
            pointsManager.savePoint(point)
        }
        
        func clearPoints() {
            pointsManager.clearPoints()
        }
    }
    
