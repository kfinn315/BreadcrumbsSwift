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
    private var managedObjectContext : NSManagedObjectContext
    
    public var currentPathAlbum : Variable<[PHAsset]?> = Variable(nil)
    public var currentPathDriver : Driver<Path?>?
    public var currentAlbumTitle : String?
    private var _currentPath : Variable<Path?> = Variable(nil)
    private let currentPathUpdateObservable = PublishSubject<Path?>()
    
    var pathsManager = PathsManager()
    var pointsManager = PointsManager()
    var pedometer = CMPedometer()
    var disposeBag = DisposeBag()
    
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
        
        
        currentPathDriver = _currentPath.asObservable().asDriver(onErrorJustReturn: nil)
        
        currentPathDriver?.drive(onNext: { [weak self] path in
            log.info("currentPathDriver onNext")
            
            self?.updatePhotoCollection(path?.albumId)
        }).disposed(by: disposeBag)
    }
    
    func setCoverImage(_ img: UIImage) {
        log.info("Set cover image")
        
        if _currentPath.value != nil, let imgdata = UIImagePNGRepresentation(img) {
            
            do {
                _currentPath.value?.coverimg = imgdata
                try self.updateCurrentPathInCoreData()
            } catch {
                log.error(error.localizedDescription)
            }
        } else{
            
        }
    }
    
    func updateCurrentAlbum(collection: PhotoCollection) {
        log.info("Update photo collection to \(collection.title)")
        
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
            (currentAlbumTitle, currentPathAlbum.value) = PhotoManager.getImages(pathid!) ?? (nil,nil)
        } else {
            currentPathAlbum.value = nil
        }
    }
    
    public func setCurrentPath(_ path: Path?) {
        log.info("set current path to \(path?.displayTitle ?? "nil")")
        _currentPath.value = path
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
        
        let path = Path(context: managedObjectContext)
        
        path.startdate = start
        path.enddate = end
        path.title = title
        path.notes = notes
        path.stepcount = stepcount
        path.id = path.identity
        
//        pathsManager.save(path: path, callback: callback)
        //            pathsManager.save(date: (start, end), title: title, notes: notes, steps: stepcount, callback: callback)
        
        
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
                    try self?.managedObjectContext.rx.update(path)
                } catch{
                    //update failed
                    log.error(error.localizedDescription)
                }
            })
        }
        
        do{
            try self.managedObjectContext.rx.update(path)
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
            points = try managedObjectContext.fetch(fetchRequest)
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
        
        // path.distance = pointDistance.distTo
        
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
        log.debug("append point")
        
        pointsManager.savePoint(point)
    }
    
    func clearPoints() {
        log.debug("clear points")
        
        pointsManager.clearPoints()
    }
    
    public func updateCurrentPathInCoreData() throws {
        log.debug("update current path in core data")
        
        guard let currentpath = _currentPath.value else {
            log.debug("currentpath.value is nil")
            return
        }
        try managedObjectContext.rx.update(currentpath)
    }
}

