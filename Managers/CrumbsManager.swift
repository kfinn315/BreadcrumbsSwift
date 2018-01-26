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
        weak var delegate : CrumbsDelegate?;
        var pedometer = CMPedometer()
        
        var currentPath : Path?
        
        var managedObjectContext : NSManagedObjectContext?
        
        private static var _shared : CrumbsManager?
        class var shared : CrumbsManager {
            if _shared == nil {
                _shared = CrumbsManager()
            }
            
            return _shared!
        }
        
        private override init() {
            super.init();
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                self.managedObjectContext = appDelegate.managedObjectContext
            }
        }
        
        func UpdateCurrentAlbum(collection: PhotoCollection) {
            guard currentPath != nil, currentPath!.id != nil else{ return }
            
            currentPath?.albumData = collection
            UpdateCurrentPath(albumid: collection.id)
        }
        
        //returns number of paths updated
        private func UpdateCurrentPath(albumid: String) {
            guard currentPath != nil, currentPath!.id != nil else{
                return
            }

            let propUpdates : [AnyHashable:Any] = ["albumId": albumid]
                
            pathsManager.updatePath(id: currentPath!.id!, properties: propUpdates, callback: {
                [weak self] count in
                
                DispatchQueue.main.async{
                    self?.delegate?.CrumbsUpdated?()
                }
            })
        }
        
        //returns number of paths updated
        func UpdateCurrentPath() {
            guard currentPath != nil, currentPath!.id != nil else{ return }
            
            pathsManager.updatePath(currentPath!, callback: { [weak self] count in
                if self != nil, let id = self?.currentPath?.id {
                    self?.currentPath = self?.pathsManager.getPath(id)
                }
                DispatchQueue.main.async{
                    self?.delegate?.CrumbsUpdated?()
                }
            })
        }
        
        func SaveNewPath(start: Date, end: Date, title: String, notes: String?) {
            var stepcount : Int64 = 0
            var distance : Double = 0.0
            
                getSteps(start, end, callback: { (data, error) -> (Void) in
                    if error == nil, let stepdata = data {
                            print("steps: \(stepdata.numberOfSteps)")
                            print("est distance: \(stepdata.distance ?? 0)")
                            stepcount = Int64(stepdata.numberOfSteps)
                            distance = stepdata.distance?.doubleValue ?? 0
                    } else {
                        print(String(describing: error))
                    }
                })
            
            pathsManager.savePath(start: start, end: end, title: title, notes: notes, steps: stepcount, distance: distance, callback: {
                [weak self] error in
                DispatchQueue.main.async{
                    self?.delegate?.CrumbSaved?(error: error)
                }
            })
        }
    
        private func getSteps(_ start: Date, _ end: Date, callback: @escaping CMPedometerHandler) {
            guard CMPedometer.isStepCountingAvailable() else{
                callback(nil, LocalError.failed(message: "step counting is not available"))
                return
            }
            
            pedometer.queryPedometerData(from: start, to: end, withHandler: callback)
            
            return
        }
        
        func addPointToData(_ point: LocalPoint) {
            print("append point");
            
            pointsManager.savePoint(point)
        }
        
        func clearPoints() {
            pointsManager.clearPoints()
        }
    }
    
