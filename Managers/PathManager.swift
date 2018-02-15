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
        
        if pathid != nil {
            (currentAlbumTitle, currentAlbumAssets.value) = PhotoManager.getImages(pathid!) ?? (nil,nil)
        } else {
            currentAlbumAssets.value = nil
        }
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
        
        var stepcount : NSNumber?
        
        getSteps(start, end, callback: { (data, error) -> Void in
            log.debug("get steps callback")
            
            guard error != nil else {
                log.error("\(error!.localizedDescription)")
                return
            }
            
            if let stepdata = data {
                log.verbose("steps: \(stepdata.numberOfSteps)")
                log.verbose("est distance: \(stepdata.distance ?? 0)")
                stepcount = stepdata.numberOfSteps//Int64(truncating: stepdata.numberOfSteps)
            } else {
                log.error("step data was nil")
            }
        })
        
        let path = Path(context: managedObjectContext!)
        
        path.startdate = start
        path.enddate = end
        path.title = title
        path.notes = notes
        path.stepcount = stepcount
        
        let pointsData = getPointsData()
        
        path.pointsJSON = pointsData.json
        path.distance = pointsData.distance as NSNumber
        
        //time duration
        if path.startdate == nil, path.enddate != nil {
            path.startdate = path.enddate
        } else if path.enddate == nil, path.startdate != nil {
            path.enddate = path.startdate
        } else if path.startdate == nil, path.enddate == nil {
            path.startdate = Date()
            path.enddate = path.startdate //now
        }
        path.duration = DateInterval(start: path.startdate!, end: path.enddate!).duration as NSNumber
        
        //get location names
        let points = pointsData.array
        if let point1 = points.first {
            CLGeocoder().reverseGeocodeLocation(CLLocation(point1.coordinates), completionHandler: { [weak self] (placemarks, error) in
                
                guard let locality = placemarks?[0].locality else {
                    log.debug("reverse geocode lookup returned no locality")
                    return
                }
                
                do{
                    log.debug("reverse geocode returned \(locality)")
                    path.locations = locality
                    try self?.managedObjectContext!.rx.update(path)
                } catch{
                    //update failed
                    log.error(error.localizedDescription)
                }
            })
        }
        
        //get map snapshot
        MapViewController().getSnapshot { snapshot, error in
            log.debug("getting map snapshot")
            guard error == nil else {
                log.error(error!.localizedDescription)
                return
            }
            
            if let coverImg = snapshot?.image {
                log.info("Set cover image")
                path.coverimg = UIImagePNGRepresentation(coverImg)
            }
        }
        
        do{
            try self.managedObjectContext!.rx.update(path)
            setCurrentPath(path)
            hasNewPath = true
            
            callback(path, nil)
        } catch {
            log.error(error.localizedDescription)
            callback(nil, error)
        }
    }
    
    private func getPointsData() -> (array: [Point], json: String?, distance: Double){
        var points : [Point] = []
        let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
        var pointsJSON : String?
        
        //        guard managedObjectContext != nil else {
        //            return
        //        }
        
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
        
        var pointDistance : (endPoint: CLLocation?, distance: CLLocationDistance) = (nil, 0.0)
        pointDistance = points.reduce(into: pointDistance, { (pointDistance, point) in
            if(pointDistance.endPoint == nil){ //first
                pointDistance.endPoint = CLLocation(point.coordinates)
            } else{
                pointDistance.distance += pointDistance.endPoint!.distance(from: CLLocation(point.coordinates))
                log.verbose("distance \(pointDistance.distance)")
            }
        })
        
        return (points, pointsJSON, pointDistance.distance)
    }
    
    private func getSteps(_ start: Date, _ end: Date, callback: @escaping CMPedometerHandler) {
        log.debug("get steps for range \(start.string) - \(end.string)")
        
        if #available(iOS 11.0, *) {
            let authStatus = CMMotionActivityManager.authorizationStatus()
            
            guard authStatus != CMAuthorizationStatus.authorized else {
                log.error("Core motion is not authorized")
                return
            }
        } else {
            // Fallback on earlier versions
            log.debug("core motion skipped due to iOS version")
        }
        
        guard CMPedometer.isStepCountingAvailable() else {
            log.debug("step counting is not available")
            
            callback(nil, LocalError.failed(message: "step counting is not available"))
            return
        }
        
        pedometer.queryPedometerData(from: start, to: end, withHandler: callback)
        
        return
    }
    
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

