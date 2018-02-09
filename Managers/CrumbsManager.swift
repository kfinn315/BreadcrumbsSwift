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
    
    class CrumbsManager {
        private var managedObjectContext : NSManagedObjectContext?

        public var currentPathAlbum : Variable<[PHAsset]?> = Variable(nil)
        public var currentPathDriver : Driver<Path?>?
        public var currentAlbumTitle : String?
        private var _currentPath : Variable<Path?> = Variable(nil)
        private let currentPathUpdateObservable = PublishSubject<Path?>()
        
        var pathsManager = PathsManager()
        var pointsManager = PointsManager()
        //weak var delegate : CrumbsDelegate?
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
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                self.managedObjectContext = appDelegate.managedObjectContext
            }
            
//            currentPath.asObservable().bind { [weak self] (path) in
//                self?.updatePhotoCollection(path?.albumId)
//
//                }.disposed(by: disposeBag)
//
            currentPathDriver = _currentPath.asObservable().asDriver(onErrorJustReturn: nil)
            currentPathDriver?.drive(onNext: { [weak self] path in self?.updatePhotoCollection(path?.albumId)
            }).disposed(by: disposeBag)
            
//            currentPathDriver? = Observable.of(_currentPath.asObservable(), currentPathUpdateObservable.asObservable()).merge().asDriver(onErrorJustReturn: nil)
            
            currentPathDriver?.drive(onNext: { [weak self] path in self?.updatePhotoCollection(path?.albumId)
            }).disposed(by: disposeBag)
        }
        
        func setCoverImg(_ img: UIImage) {
            if _currentPath.value != nil, let imgdata = UIImagePNGRepresentation(img) {
                pathsManager.updatePath(pathid: _currentPath.value!.id!, properties: ["coverimg" : imgdata], callback: { (_, error) in
                    //updated
                })
                //update subscribers here
                currentPathUpdateObservable.onNext(_currentPath.value)
            }
        }
        
        func updateCurrentAlbum(collection: PhotoCollection) {
            if _currentPath.value == nil {
                return
            }
            
            updatePhotoCollection(collection.localid)
            updateCurrentPath(albumid: collection.localid)
        }
        
        private func updatePhotoCollection(_ pathid: String?) {
            if pathid != nil {
                (currentAlbumTitle, currentPathAlbum.value) = PhotoManager.getImages(pathid!) ?? (nil,nil)
            } else {
                currentPathAlbum.value = nil
            }
        }
        
        public func setCurrentPath(_ path: Path?) {
            _currentPath.value = path
        }
        
        private func updateCurrentPath(albumid: String) {
            if _currentPath.value == nil {
                return
            }
            
            _currentPath.value?.albumId = albumid
        }
        
        public func updateCurrentPath() {
            pathsManager.updatePath(_currentPath.value!, callback: { [weak self] _, error in
                if self?._currentPath.value == nil {
                    return
                }
                
                if let id = self?._currentPath.value?.id {
                    self?._currentPath.value = self?.pathsManager.getPath(id)
                }
            })
        }
        
        func saveNewPath(start: Date, end: Date, title: String, notes: String?, callback: @escaping (Path?,Error?) -> Void) {
            var stepcount : Int64 = 0
            var distance : Double = 0.0
            
            getSteps(start, end, callback: { (data, error) -> Void in
                if error == nil, let stepdata = data {
                    print("steps: \(stepdata.numberOfSteps)")
                    print("est distance: \(stepdata.distance ?? 0)")
                    stepcount = Int64(truncating: stepdata.numberOfSteps)
                    distance = stepdata.distance?.doubleValue ?? 0
                } else {
                    print(String(describing: error))
                }
            })
            
            pathsManager.savePath(date: (start, end), title: title, notes: notes, steps: stepcount, distance: distance, callback: callback)
        }
        
        private func getSteps(_ start: Date, _ end: Date, callback: @escaping CMPedometerHandler) {
            guard CMPedometer.isStepCountingAvailable() else {
                callback(nil, LocalError.failed(message: "step counting is not available"))
                return
            }
            
            pedometer.queryPedometerData(from: start, to: end, withHandler: callback)
            
            return
        }
        
        func addPointToData(_ point: LocalPoint) {
            print("append point")
            
            pointsManager.savePoint(point)
        }
        
        func clearPoints() {
            pointsManager.clearPoints()
        }
    }
    
