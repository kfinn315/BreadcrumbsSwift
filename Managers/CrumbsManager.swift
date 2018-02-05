    //
    //  CrumbsManager.swift
    //  BreadcrumbsSwift
    //
    //  Created by Kevin Finn on 5/9/17.
    //  Copyright © 2017 Kevin Finn. All rights reserved.
    //
    
    import Foundation
    import CoreLocation
    import CoreData
    import UIKit
    import CoreMotion
    import RxCocoa
    import RxSwift
    import Photos
    
    class CrumbsManager: NSObject {//}, CloudKitDelegate {
        public var currentPath : Variable<Path?> = Variable(nil)
        public var currentPathAlbum : Variable<[PHAsset]?> = Variable(nil)
        public var currentPathDriver : Driver<Path?>?
        public var currentAlbumTitle : String?
        
        var pathsManager = PathsManager();
        var pointsManager = PointsManager();
        weak var delegate : CrumbsDelegate?;
        var pedometer = CMPedometer()
        var managedObjectContext : NSManagedObjectContext?
        var disposeBag = DisposeBag()
        
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
            
            currentPath.asObservable().bind { [weak self] (path) in
                self?.updatePhotoCollection(path?.albumId)
                }.disposed(by: disposeBag)
            
            currentPathDriver = Driver.just(currentPath.value)
        }
        
        func UpdateCurrentAlbum(collection: PhotoCollection) {
            if currentPath.value == nil {
                return
            }
            
            updatePhotoCollection(collection.id)
            UpdateCurrentPath(albumid: collection.id)
        }
        
        private func updatePhotoCollection(_ id: String?){
            if id != nil {
                (currentAlbumTitle, currentPathAlbum.value) = PhotoManager.getImages(id!) ?? (nil,nil)
            } else{
                currentPathAlbum.value = nil
            }
        }
        
        //returns number of paths updated
        private func UpdateCurrentPath(albumid: String) {
            if currentPath.value == nil {
                return
            }
            
            currentPath.value?.albumId = albumid
        }
        
        //returns number of paths updated
        func UpdateCurrentPath() {
            if currentPath.value == nil {
                return
            }
            
            pathsManager.updatePath(currentPath.value!, callback: { [weak self] count in
                if self?.currentPath.value == nil {
                    return
                }
                
                if let id = self?.currentPath.value?.id {
                    self?.currentPath.value = self?.pathsManager.getPath(id)
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
    
