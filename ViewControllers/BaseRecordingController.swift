//
//  RecordViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/7/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import CloudKit
import RxCocoa
import RxSwift

public class BaseRecordingController : UIViewController,CLLocationManagerDelegate, CrumbsDelegate {
    var recordingMgr = RecordingManager.shared
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //delegate callbacks
    func errorUpdatingLocations(_ error: Error) {
        print("Could not update locations. \(error), \(error.localizedDescription)")
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorSavingData(_ error: Error) {
        print("Could not save data. \(error), \(error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func crumbSaved(error: Error?) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
