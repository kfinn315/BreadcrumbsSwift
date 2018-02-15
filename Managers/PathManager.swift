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
import RxCoreData
import Photos

class CrumbsManager {
    private weak var managedObjectContext : NSManagedObjectContext?
    
    public var currentPathDriver : Driver<Path?>?
    public var currentAlbumDriver : Driver<PHAssetCollection?>
    public var currentAlbumTitle : String?
    private var currentAlbumAssets : Variable<PHAssetCollection?> = Variable(nil)
    private var _currentPath : Variable<Path?> = Variable(nil)
    private let currentPathSubject = BehaviorSubject<Path?>(value: nil)
    
    var pointsManager = PointsManager()
    var pedometer = CMPedometer()
    var disposeBag = DisposeBag()
    
    public var hasNewPath : Bool = false
    
    private static var _shared : CrumbsManager?
    
    public var currentPath: Path? {
        return _currentPath.value
    }
    
    class var shared : CrumbsManager {
        if _shared == nil {
            _shared = CrumbsManager()
        }
        
        return _shared!
    }
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.managedObjectContext = appDelegate.managedObjectContext
        
        //emit updates to _currentPath value
        currentPathDriver = currentPathSubject.asDriver(onErrorJustReturn: nil)
        
        currentAlbumDriver = currentAlbumAssets.asObservable().asDriver(onErrorJustReturn: nil)
        
        currentPathDriver?.drive(onNext: { [weak self] path in
            DispatchQueue.global(qos: .userInitiated).async {
                log.info("currentPathDriver onNext")
                self?.updatePhotoCollection(path?.albumId)
            }
        }).disposed(by: disposeBag)
        
        //push emit path to currentPathDriver when _currentPath emits
        _currentPath.asObservable().subscribe(onNext: { (path) in
            self.currentPathSubject.onNext(path)
        }).disposed(by: disposeBag)
        
    }
    
    
    func updateCurrentAlbum(collection: PhotoCollection) {
        log.info("Update photo album to \(collection.title)")
        
        guard _currentPath.value != nil else {
            return
        }
        
        do {
            updatePhotoCollection(collection.localid)
            _currentPath.value?.albumId = collection.localid
            try updateCurrentPathInCoreData()
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    private func updatePhotoCollection(_ pathid: String?) {
        log.info("update photo collection to \(pathid ?? "nil")")
        
        currentAlbumAssets.value = PhotoManager.getImages(pathid)        
    }
    
    public func setCurrentPath(_ path: Path?) {
        log.info("set current path to \(path?.displayTitle ?? "nil")")
        hasNewPath = false
        if( _currentPath.value?.identity != path?.identity){
            _currentPath.value = path
        }
    }
    
    func saveNewPath(start: Date, end: Date, title: String, notes: String?, callback: @escaping (Path?,Error?) -> Void) {
        log.info("saveNewPath")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let group = DispatchGroup()
            
            let path = Path(context: self.managedObjectContext!)
            path.startdate = start
            path.enddate = end
            path.title = title
            path.notes = notes
            
            let pointsData = self.getPointsData()
            path.pointsJSON = pointsData.json

            group.enter()
            self.getSteps(start, end) { steps in
                path.stepcount = steps
                group.leave()
            }
            
            group.enter()
            self.getPathDistance(pointsData.array) { distance in
                path.distance = distance as NSNumber
                group.leave()
            }

            group.enter()
            self.getPathDuration(start, end) { duration in
                path.duration = duration
                group.leave()
            }
            
            group.enter()
            self.getLocality(pointsData.array){ locality in
                path.locations = locality
                group.leave()
            }
            
            group.enter()
            self.getSnapshot() { coverimage in
                if let coverImg = coverimage {
                    log.info("Set cover image")
                    path.coverimg = UIImagePNGRepresentation(coverImg)
                }
                
                group.leave()
            }
            
            group.wait()

            do{
                try self.managedObjectContext!.rx.update(path)
                self.setCurrentPath(path)
                self.hasNewPath = true
                
                callback(path, nil)
            } catch {
                log.error(error.localizedDescription)
                callback(nil, error)
            }
        }
    }
    private func getSnapshot(_ callback: @escaping (UIImage?) -> Void){
        MapViewController().getSnapshot { snapshot, error in
            log.debug("getting map snapshot")
            guard error == nil else {
                log.error(error!.localizedDescription)
                callback(nil)
                return
            }
            
            callback(snapshot?.image)
        }
    }
    private func getLocality(_ points: [Point],_ callback: @escaping (String?) -> Void ) {
        //get location names
        if let point1 = points.first {
            CLGeocoder().reverseGeocodeLocation(CLLocation(point1.coordinates), completionHandler: { (placemarks, error) in
                guard let locality = placemarks?[0].locality else {
                    log.debug("reverse geocode lookup returned no locality")
                    callback(nil)
                    return
                }
                
                callback(locality)
            })
        }
    }
    private func getPathDuration(_ start: Date, _ end: Date,_ callback: @escaping (NSNumber) -> Void) {
//        //time duration
//        if start == nil, end != nil {
//            start = end
//        } else if path.enddate == nil, start != nil {
//            end = start
//        } else if start == nil, end == nil {
//            start = Date()
//            end = start //now
//        }
//
        
        callback(DateInterval(start: start, end: end).duration as NSNumber)
    }
    private func getPathDistance(_ points: [Point],_ callback: @escaping (CLLocationDistance) -> Void){
        var pointDistance : (endPoint: CLLocation?, distance: CLLocationDistance) = (nil, 0.0)
        pointDistance = points.reduce(into: pointDistance, { (pointDistance, point) in
            if(pointDistance.endPoint == nil){ //first
                pointDistance.endPoint = CLLocation(point.coordinates)
            } else{
                pointDistance.distance += pointDistance.endPoint!.distance(from: CLLocation(point.coordinates))
                log.verbose("distance \(pointDistance.distance)")
            }
        })
        callback(pointDistance.distance)
    }
    
    private func getPointsData() -> (array: [Point], json: String?){
        var points : [Point] = []
        let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
        var pointsJSON : String?
        
        do {
            points = try managedObjectContext!.fetch(fetchRequest)
        } catch {
            log.error("error \(error)")
        }
        
        log.verbose("saving "+String(describing: points.count)+" points to new path")
        do {
            pointsJSON = String(data: try JSONEncoder().encode(points), encoding: .utf8)
        } catch {
            log.error("error "+error.localizedDescription)
        }
        
        return (points, pointsJSON)
    }
    
    private func getSteps(_ start: Date, _ end: Date, _ callback: @escaping (NSNumber?) -> Void){
        log.debug("get steps for range \(start.string) - \(end.string)")
        
        if #available(iOS 11.0, *) {
            let authStatus = CMMotionActivityManager.authorizationStatus()
            
            if authStatus == CMAuthorizationStatus.authorized, CMPedometer.isStepCountingAvailable() {
                pedometer.queryPedometerData(from: start, to: end) {(data, error) -> Void in
                    var stepcount : NSNumber?
                    log.debug("get steps callback")
                    
                    if error == nil, let stepdata = data {
                        log.verbose("steps: \(stepdata.numberOfSteps)")
                        log.verbose("est distance: \(stepdata.distance ?? 0)")
                        stepcount = stepdata.numberOfSteps//Int64(truncating: stepdata.numberOfSteps)
                    } else {
                        log.error("error: \(error?.localizedDescription) or step data was nil")
                    }
                    
                    callback(stepcount)
                }
            } else {
                log.error("Core motion is not authorized or step counting is not available")
                callback(nil)
            }
        } else {
            // Fallback on earlier versions
            log.debug("core motion skipped due to iOS version")
            callback(nil)
        }
        
        return
    }
    //    private func getSteps(_ start: Date, _ end: Date, callback: @escaping CMPedometerHandler) {
    //
    //        return
    //    }
    //
    func addPointToData(_ point: LocalPoint) {
        log.info("append point")
        pointsManager.savePoint(point)
    }
    
    func clearPoints() {
        log.info("clear points")
        pointsManager.clearPoints()
    }
    
    public func updateCurrentPathInCoreData() throws {
        log.info("call to update current path")
        
        guard let currentpath = _currentPath.value else {
            log.error("currentpath value is nil")
            return
        }
        
        log.debug("update current path in managedObjectContext")
        try managedObjectContext!.rx.update(currentpath)
        
        currentPathSubject.onNext(currentpath)
    }
}

